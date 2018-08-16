
$SubscriptionName = 'Visual Studio Enterprise'
$stggrpUriStart = "https://dscresgrpdiag235.blob.core.windows.net/vhds/"
$sourcedisk = "https://dscresgrpdiag235.blob.core.windows.net/vhds/Win10x64_sysprepUpdated.vhd"
 
$LocationName = "eastus"
$ResourceGroupName = "dscresgrp"
$StorageAccount = "dscresgrpdiag235"
 $NetworkName = "DSCResGrp-vnet"
$NetworkName
 
# Login to Azure and Select Subscription
Login-AzureRmAccount
$xx = Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName $SubscriptionName
 
#Specify Admin Local User and Password
$VMLocalAdminUser = 'adms_sa'
#actual password is abc123. (with trailin gperiod)
$VMLocalAdminSecurePassword = ConvertTo-SecureString "2wsx@WSX2wsx" -AsPlainText -Force
 
# Set Current Storage Account
Set-AzureRmCurrentStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccount
 
# Set VM Parameters
#$OSDiskName = "Win7x64_sysprep3.vhd"
$OSDiskName = "Win10x64_sysprepUpdated.vhd"
$ComputerName = "DSCWin10-T01"
#OSDiskURI needs to be a different from SOURCEImage URI. It creates new disc from image
$OSDiskUri = $stggrpUriStart + $ComputerName +  "DiskOS.vhd" 
$OSDiskUri

# $SourceImageUri = $stggrpUriStart +  "Win7SysPreped.vhd"
# $SourceImageUri

$VMName = $ComputerName
$VMSize = "Standard_A2"
$OSDiskCaching = "ReadWrite"
$OSCreateOption = "FromImage"
 
# Set Networking Parameters
$DNSNameLabel = $ComputerName

$NICName = $ComputerName + "-NIC"


$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $NetworkName -ErrorAction Stop 

$ipName = $ComputerName + "-PIP"  
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic -Force -ErrorAction Stop
   
$Vnet.Subnets[0].Id
$NIC = New-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -ErrorAction Stop -Force
 
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword); 
 
# Set Virtual Machine Parameters
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -ErrorAction Stop
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate -ErrorAction Stop
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id -ErrorAction Stop
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -SourceImageUri $sourcedisk -Caching $OSDiskCaching -CreateOption $OSCreateOption -Windows -ErrorAction Stop


# $VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -SourceImageUri $SourceImageUri -Caching $OSDiskCaching -CreateOption $OSCreateOption -Windows


 
# Create Virtual Machine
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose -ErrorAction Stop 