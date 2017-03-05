# if(test-path Alias:\diff){
# 	Remove-Item -Force alias:diff 
# }

Task default -Depends t1, t2, t3, t4, t5, t6, t7

Task Clean {
    rm -ea 0 Files[0-9][0-9]*.wxs
}

Task t7 {

    "Remove -ag switch"
    Set-Content -Value '' -Path myFile.txt
    heat file myFile.txt -nologo -cg ProductComponents -out Files7.wxs
    cmd /c diff -uw Files6.wxs Files7.wxs

}

Task t6 {

    "Remove -sreg switch"
    Set-Content -Value '' -Path myFile.txt
    heat file myFile.txt -nologo -cg ProductComponents -ag -out Files6.wxs
    cmd /c diff -uw Files5.wxs Files6.wxs
}

Task t5 {

    "Remove -sfrag switch"
    Set-Content -Value '' -Path myFile.txt
    heat file myFile.txt -nologo -cg ProductComponents -ag -sreg -out Files5.wxs
    cmd /c diff -uw Files4.wxs Files5.wxs

}

Task t4 {

    "Remove -srd switch"
    Set-Content -Value '' -Path myFile.txt
    heat file myFile.txt -nologo -cg ProductComponents -ag -sreg -sfrag -out Files4.wxs
    cmd /c diff -uw Files4.wxs Files3.wxs

}

Task t3 {

    "Remove -var var.BuildDirectory switch"
    Set-Content -Value '' -Path myFile.txt
    heat file myFile.txt -nologo -cg ProductComponents -ag -sreg -sfrag -srd -out Files3.wxs
    cmd /c diff -uw Files3.wxs Files2.wxs

}

Task t2 {

    "Remove -dr INSTALLFOLDER switch"
    Set-Content -Value '' -Path myFile.txt
    heat file myFile.txt -nologo -cg ProductComponents -ag -sreg -sfrag -srd -out Files2.wxs -var var.BuildDirectory
    cmd /c diff -uw Files1.wxs Files2.wxs

}

Task t1 {

    "Original"
    Set-Content -Value '' -Path myFile.txt
    heat file myFile.txt -nologo -cg ProductComponents -ag -sreg -sfrag -srd -out Files1.wxs -var var.BuildDirectory -dr INSTALLFOLDER
	
}
