<#
Prerequisites: VHD image with Windows OS installed and SYSPREPPED
To create VHD image, please refer to the link below
https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-upload-image/
#>

# Login to Azure and Select Subscription
Login-AzureRmAccount

$SubscriptionName = "ADMS Development 3"
  
$LocationName = "East US"
$ResourceGroupName = "dscResGrp"
$StorageAccount = "dscadmsstorage"
$VHDname = "Win10April2018.vhd"
$ComputerName = "Win10-t5"
$imageName = "myWin10image"
$CustomerCode = "dsc"
$NetworkName = $CustomerCode + "VirtualNetwork"
$SubnetName = "Production"
$NSGName = $CustomerCode + "VirtualNetwork-NSG"
$NSG = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName

Select-AzureRmSubscription -SubscriptionName $SubscriptionName


$SourceImageUri = "https://$($StorageAccount).blob.core.windows.net/vhds/$($VHDname)"
#Added New Lines from    
#reference https://docs.microsoft.com/en-us/azure/virtual-machines/windows/upload-generalized-managed?toc=%2Fazure%2Fvirtual-machines%2Fwindows%2Ftoc.json

#Create the image using generalized OS VHD
$imageConfig = New-AzureRmImageConfig `
   -Location $LocationName
$imageConfig = Set-AzureRmImageOsDisk `
   -Image $imageConfig `
   -OsType 'Windows' `
   -OsState 'Generalized' `
   -BlobUri $SourceImageUri
   New-AzureRmImage `
   -ImageName $imageName `
   -ResourceGroupName $ResourceGroupName `
   -Image $imageConfig


   #Create the VM

    
