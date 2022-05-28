Write-Output "Warning: the authentication window may be under the 'Current Score' window..."
$c = Connect-AzAccount -WarningAction SilentlyContinue
if (!$c)  {
  Write-Output "Not connected, exiting."
  Exit
}

Write-Output "Connected."
$ts = Get-AzTenant | Select-Object Id, Name, @{l = "Domain Names"; e = {$d = "$($_.Domains)".Replace(" ", ", "); if ($d.Length -Le 50) {$d} else {"$($d.Substring(0, 47))..."}}}
if ($ts.Count -Eq 0) {
  Write-Output "No tenants accessible by this user, exiting."
  Exit
}

$ssl = @()

foreach ($t in $ts) {
  $ss = Get-AzSubscription -TenantId $t.Id | Select-Object Id, Name
  if ($ss.Count -Ne 0) {
    Write-Output """$($t.Name)"", ""$($t.'Domain Names')"", $($t.Id)"
    $ssl += [PSCustomObject]@{
      'Tenant Name' = "$($t.Name)"
      'Domain Names' = "$($t.'Domain Names')"
      'Tenant Id' = "$($t.Id)"
      'Subscription Name' = ""
      'Subscription Id' = ""
      'Score Name' = ""
      'Component Name' = ""
      'Current Score' = ""
      'Maximum Score' = ""
      Percentage = ""
      Weight = ""
      'Healthy Resources' = ""
      'Unhealthy Resources' = ""
    }
    foreach ($s in $ss) {
      Write-Output "  ""$($s.Name)"", $($s.Id)"
      $ssl += [PSCustomObject]@{
        'Tenant Name' = ""
        'Domain Names' = ""
        'Tenant Id' = ""
        'Subscription Name' = "$($s.Name)"
        'Subscription Id' = "$($s.Id)"
        'Score Name' = ""
        'Component Name' = ""
        'Current Score' = ""
        'Maximum Score' = ""
        Percentage = ""
        Weight = ""
        'Healthy Resources' = ""
        'Unhealthy Resources' = ""
      }
      Select-AzSubscription -Tenant $t.Id -Subscription $s.Id | Out-Null
      $ss = Get-AzSecuritySecureScore | Select-Object DisplayName, CurrentScore, MaxScore, @{l = "Percent"; e = {"$([Math]::Round($_.Percentage*100, 2))%"}}, Weight
      if (!$ss) {
        Write-Output "    Secure Score inacessible by this user."
        $ssl += [PSCustomObject]@{
          'Tenant Name' = ""
          'Domain Names' = ""
          'Tenant Id' = ""
          'Subscription Name' = ""
          'Subscription Id' = "Secure Score inacessible by this user."
          'Score Name' = ""
          'Component Name' = ""
          'Current Score' = ""
          'Maximum Score' = ""
          Percentage = ""
          Weight = ""
          'Healthy Resources' = ""
          'Unhealthy Resources' = ""
        }
      } else {
        Write-Output "    $($ss.DisplayName) - Current: $($ss.CurrentScore), Max: $($ss.MaxScore), Percent: $($ss.Percent), Weight: $($ss.Weight)"
        $ssl += [PSCustomObject]@{
          'Tenant Name' = ""
          'Domain Names' = ""
          'Tenant Id' = ""
          'Subscription Name' = ""
          'Subscription Id' = ""
          'Score Name' = "$($ss.DisplayName)"
          'Component Name' = ""
          'Current Score' = "$($ss.CurrentScore)"
          'Maximum Score' = "$($ss.MaxScore)"
          Percentage = "$($ss.Percent)"
          Weight = "$($ss.Weight)"
          'Healthy Resources' = ""
          'Unhealthy Resources' = ""
        }
        $sscs = Get-AzSecuritySecureScoreControl | Select-Object DisplayName, CurrentScore, MaxScore, @{l = "Percent"; e = {"$([Math]::Round($_.Percentage*100, 2))%"}}, Weight, HealthyResourceCount, UnhealthyResourceCount
        foreach ($ssc in $sscs) {
          Write-Output "      $($ssc.DisplayName) - Current: $($ssc.CurrentScore), Max: $($ssc.MaxScore), Percent: $($ssc.Percent), Weight: $($ssc.Weight), Healthy Resources: $($ssc.HealthyResourceCount), Unhealthy Resources: $($ssc.UnhealthyResourceCount)"
          $ssl += [PSCustomObject]@{
            'Tenant Name' = ""
            'Domain Names' = ""
            'Tenant Id' = ""
            'Subscription Name' = ""
            'Subscription Id' = ""
            'Score Name' = ""
            'Component Name' = "$($ssc.DisplayName)"
            'Current Score' = "$($ssc.CurrentScore)"
            'Maximum Score' = "$($ssc.MaxScore)"
            Percentage = "$($ssc.Percent)"
            Weight = "$($ssc.Weight)"
            'Healthy Resources' = "$($ssc.HealthyResourceCount)"
            'Unhealthy Resources' = "$($ssc.UnhealthyResourceCount)"
          }
        }
      }
    }
  }
}
$emptyTenantsNotYetFound = $True
foreach ($t in $ts) {
  $ss = Get-AzSubscription -TenantId $t.Id | Select-Object Id, Name
  if ($ss.Count -Eq 0) {
    if ($emptyTenantsNotYetFound) {
      Write-Output "No subscriptions accessible by this user under this(ese) tenant(s)."
      $ssl += [PSCustomObject]@{
        'Tenant Name' = ""
        'Domain Names' = ""
        'Tenant Id' = ""
        'Subscription Name' = ""
        'Subscription Id' = ""
        'Score Name' = ""
        'Component Name' = ""
        'Current Score' = ""
        'Maximum Score' = ""
        Percentage = ""
        Weight = ""
        'Healthy Resources' = ""
        'Unhealthy Resources' = ""
      }
      $ssl += [PSCustomObject]@{
        'Tenant Name' = "No subscriptions accessible by this user under this(ese) tenant(s)."
        'Domain Names' = ""
        'Tenant Id' = ""
        'Subscription Name' = ""
        'Subscription Id' = ""
        'Score Name' = ""
        'Component Name' = ""
        'Current Score' = ""
        'Maximum Score' = ""
        Percentage = ""
        Weight = ""
        'Healthy Resources' = ""
        'Unhealthy Resources' = ""
      }
      $ssl += [PSCustomObject]@{
        'Tenant Name' = ""
        'Domain Names' = ""
        'Tenant Id' = ""
        'Subscription Name' = ""
        'Subscription Id' = ""
        'Score Name' = ""
        'Component Name' = ""
        'Current Score' = ""
        'Maximum Score' = ""
        Percentage = ""
        Weight = ""
        'Healthy Resources' = ""
        'Unhealthy Resources' = ""
      }
      $emptyTenantsNotYetFound = $False
    }
    Write-Output "  ""$($t.Name)"", ""$($t.'Domain Names')"", $($t.Id)"
    $ssl += [PSCustomObject]@{
      'Tenant Name' = "$($t.Name)"
      'Domain Names' = "$($t.'Domain Names')"
      'Tenant Id' = "$($t.Id)"
      'Subscription Name' = ""
      'Subscription Id' = ""
      'Score Name' = ""
      'Component Name' = ""
      'Current Score' = ""
      'Maximum Score' = ""
      Percentage = ""
      Weight = ""
      'Healthy Resources' = ""
      'Unhealthy Resources' = ""
    }
  }
}

$ssl | Export-Csv -Path "x.csv" -NoTypeInformation -Delimiter "," -Encoding utf8
