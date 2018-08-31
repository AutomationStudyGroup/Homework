$SubscriptionName = "TEST Training Lab"
$LocationName = "East US"
$ResourceGroupName = "LAB01ResGrp"
$StorageAccount = "LAB01TESTstorage"

$CustomerCode = "LAB01"
$ComputerName = $CustomerCode + "App3"
$VMSize = "Standard_E2S_V3"
#$Offerring = "WindowsServer"
$Offerring = "MicrosoftSharePointServer"
#$WindowsServerSkus = "2016-Datacenter"
$WindowsServerSkus = "2016"

#Specify Admin Local User and Password
$VMLocalAdminUser = 'TEST_sa'
$VMLocalAdminSecurePassword = ConvertTo-SecureString "PutYourPasswordHere" -AsPlainText -Force


# Login to Azure and Select Subscription
#Login-AzureRmAccount
Get-AzureRmSubscription -SubscriptionName $SubscriptionName | Select-AzureRmSubscription


# Set Current Storage Account
Set-AzureRmCurrentStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccount

# Set VM Parameters

$OSDiskName = "$ComputerName.vhd"
$OSDiskUri = "https://LAB01TESTstorage.blob.core.windows.net/vhds/$ComputerName.vhd"
$VMName = $ComputerName
$OSDiskCaching = "ReadWrite"


# Set Networking Parameters
$NetworkName = $CustomerCode + "VirtualNetwork"
$NICName = "$ComputerName-NIC"
$NSG = $CustomerCode + "VirtualNetwork-NSG"
$SubnetName = "Production"
$PIPName = "$ComputerName-PIP"

$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $NetworkName
$SubnetID = (Get-AzureRmVirtualNetworkSubnetConfig -Name "production" -VirtualNetwork $Vnet).Id

$PIp = New-AzureRmPublicIpAddress -Name $PIPName -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
$NIC = New-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $SubnetID -PublicIpAddressId $pip.Id


$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword); 

# Set Virtual Machine Parameters
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate

$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftSharePoint" -Offer "MicrosoftSharePointServer" -Skus "2016" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

# Create Virtual Machine
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose  

