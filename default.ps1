Task default -Depends msi120
Task msi120 -Depends `
  Clean10, `
  UnInstall10, `
  CheckInstalled10, `
  Setup10, `
  Harvest90, `
  Candle20, `
  Light30, `
  CheckInstalled10, `
  Install10, `
  TestInstalled

Task msi110 -Depends Clean10, Setup10, Harvest90
Task msi100 -Depends Clean10, Setup10, Harvest80, Candle20, Light30
Task msi90 -Depends Clean10, Setup10, Harvest70, Candle10, Light20, Install10
Task msi80 -Depends Clean10, Setup10, Harvest70, Candle10, Light10, Install10
Task msi70 -Depends Clean10, Setup10, Harvest60, Candle10, Light10
Task msi60 -Depends Clean10, Setup10, Harvest50, Candle10, Light10
Task msi50 -Depends Clean10, Setup10, Harvest40, Candle10, Light10
Task msi40 -Depends Clean10, Setup10, Harvest30, Candle10, Light10
Task msi30 -Depends Setup10, Harvest20, Candle10, Light10
Task msi20 -Depends Setup10, Harvest10, Candle10, Light10
Task msi10 -Depends Clean10, Setup10, Harvest10, Candle10, Light10

Task TidyXML {
    tidy -xml --tidy-mark no --doctype strict --wrap-attributes false -q -i -wrap 1000 -m  Product.wxs
}


Task GitResetTempWorkaround {
    Write-Host "FIXME: workaround flail in Product.wxs"
    git checkout -- Product.wxs
}

Task Install20 {
    $msiexecd = Get-Process -Name 'msiexec'
    msiexec /q /L*v myInstaller.log /i myInstaller.msi
    $myMsi = Get-Process -Name 'msiexec' |
    Where-Object { $_.Id -ne $msiexecd.Id }
    $myMsi.WaitForExit()
    Write-Verbose $myMsi.ExitCode
    Write-Host "Install status: $lastExitCode"

}

Task TestInstalled {
    # FIXME: consider using pester here
    $glob = "${env:SYSTEMDRIVE}/Program*/My Company/My Product/[12].txt"
    $c = (Get-ChildItem $glob -ea 0 | Select-Object -exp fullname | Measure-Object).Count
    Assert ($c -eq 2) "count of files installed should be 2"
}

Task CheckInstalled10 {
    # FIXME: (use pester?) here instead of manual check
    $glob = "${env:SYSTEMDRIVE}/Program*/My Company/My Product/[12].txt"
    Get-ChildItem $glob -ea 0 | Select-Object -exp fullname
}

Task UnInstall10 {
    msiexec /q /X myInstaller.msi /L*v myInstaller.log
    # FIXME: checking exit code here is misleading/incorrect
    Write-Host "Uninstall status: $lastExitCode"
}

Task Install10 {
    msiexec /q /L*v myInstaller.log /i myInstaller.msi
    # FIXME: checking exit code here is misleading/incorrect
    Write-Host "Install status: $lastExitCode"

}


Task Light30 {
    light `
	  -nologo `
	  -out myInstaller.msi `
	  -sval Product.wixobj `
	  -sval Files.wixobj `
	  -ext WixUIExtension `
	  -ext WixUtilExtension
}

Task Light20 {
    light `
	  -nologo `
	  -out myInstaller.msi `
	  -ext WixUIExtension `
	  -ext WixUtilExtension
}


Task Light10 {
    light `
	  -nologo `
	  -out myInstaller.msi `
	  -sval mySource.wixobj `
	  -ext WixUIExtension `
	  -ext WixUtilExtension
}

Task Candle20 {

    candle Files.wxs `
	  -nologo `
	  -dBuildDirectory=mySource `
	  -ext WixUtilExtension

    candle Product.wxs `
	  -nologo `
	  -ext WixUtilExtension
}

Task Candle10 {
    candle mySource.wxs `
	  -nologo `
	  -dSourceDir=mySource `
	  -ext WixUtilExtension
}

Task Harvest90 {

    heat dir mySource `
	  -nologo `
	  -cg ProductComponents `
	  -ag `
	  -sreg `
	  -sfrag `
	  -srd `
	  -out Files.wxs `
	  -var var.BuildDirectory `
	  -dr INSTALLFOLDER

    (Get-Content Product.wxs) |
    Where-Object {$_ -notlike '*Cabinet="product.cab"*'} |
    Set-Content Product.wxs

    (Get-Content Product.wxs) -replace 'PUT-GUID-HERE', [guid]::NewGuid() `
	  -replace 'PUT-COMPANY-NAME-HERE', 'My Company' `
	  -replace 'PUT-PRODUCT-NAME-HERE', 'My Product' `
	  -replace 'PUT-FEATURE-TITLE-HERE', 'My Feature Title' `
	  -replace 'PUT-GUID-HERE', [guid]::NewGuid() | Set-Content Product.wxs


}

Task Harvest80 {
    heat dir mySource `
	  -nologo `
	  -cg ProductComponents `
	  -ag `
	  -sreg `
	  -sfrag `
	  -out Files.wxs `
	  -var var.BuildDirectory `
	  -dr INSTALLFOLDER

    heat dir mySource `
	  -nologo `
	  -srd -var "var.BinDir" `
	  -dr INSTALLFOLDER `
	  -ag `
	  -g1 `
	  -sf `
	  -srd `
	  -template product `
	  -out Product.wxs


    (Get-Content Product.wxs) |
    Where-Object {$_ -notlike '*Cabinet="product.cab"*'} |
    Set-Content Product.wxs

    (Get-Content Product.wxs) -replace 'PUT-GUID-HERE', [guid]::NewGuid() `
	  -replace 'PUT-COMPANY-NAME-HERE', 'My Company' `
	  -replace 'PUT-PRODUCT-NAME-HERE', 'My Product' `
	  -replace 'PUT-FEATURE-TITLE-HERE', 'My Feature Title' `
	  -replace 'PUT-GUID-HERE', [guid]::NewGuid() | Set-Content Product.wxs


}


Task Harvest70 {
    heat dir mySource `
	  -nologo `
	  -ag `
	  -g1 `
	  -sf `
	  -srd `
	  -template product `
	  -out mySource.wxs

    (Get-Content mySource.wxs) |
    Where-Object {$_ -notlike '*Cabinet="product.cab"*'} |
    Set-Content mySource.wxs

    (Get-Content mySource.wxs) -replace 'PUT-GUID-HERE', [guid]::NewGuid() `
	  -replace 'PUT-COMPANY-NAME-HERE', 'My Company' `
	  -replace 'PUT-PRODUCT-NAME-HERE', 'My Product' `
	  -replace 'PUT-FEATURE-TITLE-HERE', 'My Feature Title' `
	  -replace 'PUT-GUID-HERE', [guid]::NewGuid() | Set-Content mySource.wxs
}
Task Harvest60 {
    heat dir mySource `
	  -nologo `
	  -ag `
	  -g1 `
	  -sf `
	  -srd `
	  -template product `
	  -out mySource.wxs

    (Get-Content mySource.wxs) -replace 'PUT-GUID-HERE', [guid]::NewGuid() `
	  -replace 'PUT-COMPANY-NAME-HERE', 'My Company' `
	  -replace 'PUT-PRODUCT-NAME-HERE', 'My Product' `
	  -replace 'PUT-FEATURE-TITLE-HERE', 'My Feature Title' `
	  -replace 'PUT-GUID-HERE', [guid]::NewGuid() | Set-Content mySource.wxs
}

Task Harvest50 {
    heat dir mySource `
	  -nologo `
	  -cg ConfigurationUtilityComponents `
	  -ag `
	  -g1 `
	  -sf `
	  -srd `
	  -template product `
	  -out mySource.wxs

    (Get-Content mySource.wxs) -replace 'PUT-GUID-HERE', [guid]::NewGuid() `
	  -replace 'PUT-COMPANY-NAME-HERE', 'My Company' `
	  -replace 'PUT-PRODUCT-NAME-HERE', 'My Product' `
	  -replace 'PUT-FEATURE-TITLE-HERE', 'My Feature Title' `
	  -replace 'PUT-GUID-HERE', [guid]::NewGuid() | Set-Content mySource.wxs
}

Task Harvest40 {
    heat dir mySource `
	  -nologo `
	  -dr ConfigurationUtilityDir `
	  -cg ConfigurationUtilityComponents `
	  -ag `
	  -g1 `
	  -sf `
	  -srd `
	  -template product `
	  -out mySource.wxs

    (Get-Content mySource.wxs) -replace 'PUT-GUID-HERE', [guid]::NewGuid() `
	  -replace 'PUT-COMPANY-NAME-HERE', 'My Company' `
	  -replace 'PUT-PRODUCT-NAME-HERE', 'My Product' `
	  -replace 'PUT-FEATURE-TITLE-HERE', 'My Feature Title' `
	  -replace 'PUT-GUID-HERE', [guid]::NewGuid() | Set-Content mySource.wxs
}

Task CreateProduct {
    @"

"@
}


Task Harvest30 `
  -precondition { return !(test-path mySource.wxs)} {
    heat dir mySource `
		-nologo `
		-dr ConfigurationUtilityDir `
		-cg ConfigurationUtilityComponents `
		-ag `
		-g1 `
		-sf `
		-srd `
		-out mySource.wxs
}

Task Harvest20 `
  -precondition { return !(test-path mySource.wxs)} {
    heat dir mySource `
		-nologo `
		-dr ConfigurationUtilityDir `
		-cg ConfigurationUtilityComponents `
		-gg `
		-g1 `
		-sf `
		-srd `
		-out mySource.wxs
}

Task Harvest10 {
    heat dir mySource `
	  -nologo `
	  -dr ConfigurationUtilityDir `
	  -cg ConfigurationUtilityComponents `
	  -gg `
	  -g1 `
	  -sf `
	  -srd `
	  -out mySource.wxs
}

Task Setup10 {
    New-Item -Force -ItemType Directory -Path mySource >$null
    Set-Content -value 1 -path mySource/1.txt
    Set-Content -value 2 -path mySource/2.txt
}

Task Clean10 {

    $fList = @(
        'Files.wxs'
        ,'*.wixpdb'
        ,'*.wixobj'
        ,'*.log'
        ,'*.msi'
    )

    foreach ($glob in $fList) {
        if(test-path $glob) {
            Remove-Item $glob
        }
    }

    if(test-path mySource){
        Remove-Item -Recurse -Force mySource
    }
}
