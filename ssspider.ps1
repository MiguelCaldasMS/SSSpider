Write-Output "Warning: the authentication window may be under the current window..."
$c = Connect-AzAccount -WarningAction SilentlyContinue
if (!$c)  {
  Write-Output "Not connected, exiting."
  Exit
}

Write-Output "Connected."
$ts = Get-AzTenant | Select-Object Id, Name, @{l = "DomainNames"; e = {$d = "$($_.Domains)".Replace(" ", ", "); if ($d.Length -Le 50) {$d} else {"$($d.Substring(0, 47))..."}}}
if ($ts.Count -Eq 0) {
  Write-Output "No tenants accessible by this user, exiting."
  Exit
}

$ssl = @()
$ssl += [PSCustomObject]@{
  tenantName = "Tenant Name"
  domainNames = "Domain Names"
  tenantId = "Tenant ID"
  subscriptionName = "Subscription Name"
  subscriptionId = "Subscription Id"
  global = "Global"
  component = "Component"
  current = "Current"
  max = "Max"
  percent = "Percent"
  weight = "Weight"
  healthyResources = "Healthy Resources"
  unhealthyResources = "Unhealthy Resources"
}

foreach ($t in $ts) {
  $ss = Get-AzSubscription -TenantId $t.Id | Select-Object Id, Name
  if ($ss.Count -Ne 0) {
    Write-Output """$($t.Name)"", ""$($t.DomainNames)"", $($t.Id)"
    $ssl += [PSCustomObject]@{
      tenantName = "$($t.Name)"
      domainNames = "$($t.DomainNames)"
      tenantId= "$($t.Id)"
      subscriptionName = ""
      subscriptionId = ""
      global = ""
      component = ""
      current = ""
      max = ""
      percent = ""
      weight = ""
      healthyResources = ""
      unhealthyResources = ""
    }
    foreach ($s in $ss) {
      Write-Output "  ""$($s.Name)"", $($s.Id)"
      $ssl += [PSCustomObject]@{
        tenantName = ""
        domainNames = ""
        tenantId = ""
        subscriptionName = "$($s.Name)"
        subscriptionId = "$($s.Id)"
        global = ""
        component = ""
        current = ""
        max = ""
        percent = ""
        weight = ""
        healthyResources = ""
        unhealthyResources = ""
      }
      Select-AzSubscription -Tenant $t.Id -Subscription $s.Id | Out-Null
      $ss = Get-AzSecuritySecureScore | Select-Object DisplayName, CurrentScore, MaxScore, @{l = "Percent"; e = {"$([Math]::Round($_.Percentage*100, 2))%"}}, Weight
      if (!$ss) {
        Write-Output "    Secure Score inacessible by this user."
        $ssl += [PSCustomObject]@{
          tenantName = ""
          domainNames = ""
          tenantId = ""
          subscriptionName = ""
          subscriptionId = "Secure Score inacessible by this user."
          global = ""
          component = ""
          current = ""
          max = ""
          percent = ""
          weight = ""
          healthyResources = ""
          unhealthyResources = ""
        }
      } else {
        Write-Output "    $($ss.DisplayName) - Current: $($ss.CurrentScore), Max: $($ss.MaxScore), Percent: $($ss.Percent), Weight: $($ss.Weight)"
        $ssl += [PSCustomObject]@{
          tenantName = ""
          domainNames = ""
          tenantId = ""
          subscriptionName = ""
          subscriptionId = ""
          global = "$($ss.DisplayName)"
          component = ""
          current = "$($ss.CurrentScore)"
          max = "$($ss.MaxScore)"
          percent = "$($ss.Percent)"
          weight = "$($ss.Weight)"
          healthyResources = ""
          unhealthyResources = ""
        }
        $sscs = Get-AzSecuritySecureScoreControl | Select-Object DisplayName, CurrentScore, MaxScore, @{l = "Percent"; e = {"$([Math]::Round($_.Percentage*100, 2))%"}}, Weight, HealthyResourceCount, UnhealthyResourceCount
        foreach ($ssc in $sscs) {
          Write-Output "      $($ssc.DisplayName) - Current: $($ssc.CurrentScore), Max: $($ssc.MaxScore), Percent: $($ssc.Percent), Weight: $($ssc.Weight), Healthy Resources: $($ssc.HealthyResourceCount), Unhealthy Resources: $($ssc.UnhealthyResourceCount)"
          $ssl += [PSCustomObject]@{
            tenantName = ""
            domainNames = ""
            tenantId = ""
            subscriptionName = ""
            subscriptionId = ""
            global = ""
            component = "$($ssc.DisplayName)"
            current = "$($ssc.CurrentScore)"
            max = "$($ssc.MaxScore)"
            percent = "$($ssc.Percent)"
            weight = "$($ssc.Weight)"
            healthyResources = "$($ssc.HealthyResourceCount)"
            unhealthyResources = "$($ssc.UnhealthyResourceCount)"
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
        tenantName = ""
        domainNames = ""
        tenantId = ""
        subscriptionName = ""
        subscriptionId = ""
        global = ""
        component = ""
        current = ""
        max = ""
        percent = ""
        weight = ""
        healthyResources = ""
        unhealthyResources = ""
      }
      $ssl += [PSCustomObject]@{
        tenantName = "No subscriptions accessible by this user under this(ese) tenant(s)."
        domainNames = ""
        tenantId = ""
        subscriptionName = ""
        subscriptionId = ""
        global = ""
        component = ""
        current = ""
        max = ""
        percent = ""
        weight = ""
        healthyResources = ""
        unhealthyResources = ""
      }
      $ssl += [PSCustomObject]@{
        tenantName = ""
        domainNames = ""
        tenantId = ""
        subscriptionName = ""
        subscriptionId = ""
        global = ""
        component = ""
        current = ""
        max = ""
        percent = ""
        weight = ""
        healthyResources = ""
        unhealthyResources = ""
      }
      $emptyTenantsNotYetFound = $False
    }
    Write-Output "  ""$($t.Name)"", ""$($t.DomainNames)"", $($t.Id)"
    $ssl += [PSCustomObject]@{
      tenantName = "$($t.Name)"
      domainNames = "$($t.DomainNames)"
      tenantId = "$($t.Id)"
      subscriptionName = ""
      subscriptionId = ""
      global = ""
      component = ""
      current = ""
      max = ""
      percent = ""
      weight = ""
      healthyResources = ""
      unhealthyResources = ""
    }
  }
}

$ssl | Export-Csv -Path "x.csv" -NoTypeInformation -Delimiter "," -Encoding utf8
