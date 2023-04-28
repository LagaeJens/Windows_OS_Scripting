Set-ADForest -Identity intranet.com -UPNSuffixes @{Add = "@abc.com" }


# command to check UPN suffixes
#? Get-ADForest -Identity intranet.com | Select-Object UPNSuffixes
