{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "virtualMachines_sush_adminPassword": {
            "defaultValue": null,
            "type": "SecureString"
        },
        "virtualMachines_sush_name": {
            "defaultValue": "sush",
            "type": "String"
        },
        "networkInterfaces_sush386_name": {
            "defaultValue": "sush386",
            "type": "String"
        },
        "networkSecurityGroups_sush_nsg_name": {
            "defaultValue": "sush-nsg",
            "type": "String"
        },
        "publicIPAddresses_sush_ip_name": {
            "defaultValue": "sush-ip",
            "type": "String"
        },
        "virtualNetworks_sush_vnet_name": {
            "defaultValue": "sush-vnet",
            "type": "String"
        },
        "storageAccounts_sushdiag140_name": {
            "defaultValue": "sushdiag140",
            "type": "String"
        },
        "storageAccounts_sushdisks813_name": {
            "defaultValue": "sushdisks813",
            "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "comments": "Generalized from resource: '/subscriptions/7eab3893-bd71-4690-84a5-47624df0b0e5/resourceGroups/sush/providers/Microsoft.Compute/virtualMachines/sush'.",
            "type": "Microsoft.Compute/virtualMachines",
            "name": "[parameters('virtualMachines_sush_name')]",
            "apiVersion": "2015-06-15",
            "location": "eastus",
            "properties": {
                "hardwareProfile": {
                    "vmSize": "Standard_DS13_v2"
                },
                "storageProfile": {
                    "imageReference": {
                        "publisher": "MicrosoftSQLServer",
                        "offer": "SQL2016SP1-WS2016",
                        "sku": "Enterprise",
                        "version": "latest"
                    },
                    "osDisk": {
                        "name": "[parameters('virtualMachines_sush_name')]",
                        "createOption": "FromImage",
                        "vhd": {
                            "uri": "[concat('https', '://', parameters('storageAccounts_sushdisks813_name'), '.blob.core.windows.net', concat('/vhds/', parameters('virtualMachines_sush_name'),'20170220112712.vhd'))]"
                        },
                        "caching": "ReadWrite"
                    },
                    "dataDisks": [
                        {
                            "lun": 0,
                            "name": "[concat(parameters('virtualMachines_sush_name'),'-disk-1')]",
                            "createOption": "Empty",
                            "vhd": {
                                "uri": "[concat('https', '://', parameters('storageAccounts_sushdisks813_name'), '.blob.core.windows.net', concat('/vhds/', parameters('virtualMachines_sush_name'),'-disk-1-20170220112712.vhd'))]"
                            },
                            "caching": "ReadOnly",
                            "diskSizeGB": 1023
                        }
                    ]
                },
                "osProfile": {
                    "computerName": "[parameters('virtualMachines_sush_name')]",
                    "adminUsername": "[parameters('virtualMachines_sush_name')]",
                    "windowsConfiguration": {
                        "provisionVMAgent": true,
                        "enableAutomaticUpdates": true
                    },
                    "secrets": [],
                    "adminPassword": "[parameters('virtualMachines_sush_adminPassword')]"
                },
                "networkProfile": {
                    "networkInterfaces": [
                        {
                            "id": "[resourceId('Microsoft.Network/networkInterfaces', parameters('networkInterfaces_sush386_name'))]"
                        }
                    ]
                }
            },
            "resources": [],
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccounts_sushdisks813_name'))]",
                "[resourceId('Microsoft.Network/networkInterfaces', parameters('networkInterfaces_sush386_name'))]"
            ]
        },
        {
            "comments": "Generalized from resource: '/subscriptions/7eab3893-bd71-4690-84a5-47624df0b0e5/resourceGroups/sush/providers/Microsoft.Network/networkInterfaces/sush386'.",
            "type": "Microsoft.Network/networkInterfaces",
            "name": "[parameters('networkInterfaces_sush386_name')]",
            "apiVersion": "2016-03-30",
            "location": "eastus",
            "properties": {
                "ipConfigurations": [
                    {
                        "name": "ipconfig1",
                        "properties": {
                            "privateIPAddress": "10.5.0.4",
                            "privateIPAllocationMethod": "Dynamic",
                            "publicIPAddress": {
                                "id": "[resourceId('Microsoft.Network/publicIPAddresses', parameters('publicIPAddresses_sush_ip_name'))]"
                            },
                            "subnet": {
                                "id": "[concat(resourceId('Microsoft.Network/virtualNetworks', parameters('virtualNetworks_sush_vnet_name')), '/subnets/default')]"
                            }
                        }
                    }
                ],
                "dnsSettings": {
                    "dnsServers": []
                },
                "enableIPForwarding": false,
                "networkSecurityGroup": {
                    "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('networkSecurityGroups_sush_nsg_name'))]"
                }
            },
            "resources": [],
            "dependsOn": [
                "[resourceId('Microsoft.Network/publicIPAddresses', parameters('publicIPAddresses_sush_ip_name'))]",
                "[resourceId('Microsoft.Network/virtualNetworks', parameters('virtualNetworks_sush_vnet_name'))]",
                "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('networkSecurityGroups_sush_nsg_name'))]"
            ]
        },
        {
            "comments": "Generalized from resource: '/subscriptions/7eab3893-bd71-4690-84a5-47624df0b0e5/resourceGroups/sush/providers/Microsoft.Network/networkSecurityGroups/sush-nsg'.",
            "type": "Microsoft.Network/networkSecurityGroups",
            "name": "[parameters('networkSecurityGroups_sush_nsg_name')]",
            "apiVersion": "2016-03-30",
            "location": "eastus",
            "properties": {
                "securityRules": [
                    {
                        "name": "default-allow-rdp",
                        "properties": {
                            "protocol": "TCP",
                            "sourcePortRange": "*",
                            "destinationPortRange": "3389",
                            "sourceAddressPrefix": "*",
                            "destinationAddressPrefix": "*",
                            "access": "Allow",
                            "priority": 1000,
                            "direction": "Inbound"
                        }
                    }
                ]
            },
            "resources": [],
            "dependsOn": []
        },
        {
            "comments": "Generalized from resource: '/subscriptions/7eab3893-bd71-4690-84a5-47624df0b0e5/resourceGroups/sush/providers/Microsoft.Network/publicIPAddresses/sush-ip'.",
            "type": "Microsoft.Network/publicIPAddresses",
            "name": "[parameters('publicIPAddresses_sush_ip_name')]",
            "apiVersion": "2016-03-30",
            "location": "eastus",
            "properties": {
                "publicIPAllocationMethod": "Dynamic",
                "idleTimeoutInMinutes": 4
            },
            "resources": [],
            "dependsOn": []
        },
        {
            "comments": "Generalized from resource: '/subscriptions/7eab3893-bd71-4690-84a5-47624df0b0e5/resourceGroups/sush/providers/Microsoft.Network/virtualNetworks/sush-vnet'.",
            "type": "Microsoft.Network/virtualNetworks",
            "name": "[parameters('virtualNetworks_sush_vnet_name')]",
            "apiVersion": "2016-03-30",
            "location": "eastus",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "10.5.0.0/24"
                    ]
                },
                "subnets": [
                    {
                        "name": "default",
                        "properties": {
                            "addressPrefix": "10.5.0.0/24"
                        }
                    }
                ]
            },
            "resources": [],
            "dependsOn": []
        },
        {
            "comments": "Generalized from resource: '/subscriptions/7eab3893-bd71-4690-84a5-47624df0b0e5/resourceGroups/sush/providers/Microsoft.Storage/storageAccounts/sushdiag140'.",
            "type": "Microsoft.Storage/storageAccounts",
            "sku": {
                "name": "Standard_LRS",
                "tier": "Standard"
            },
            "kind": "Storage",
            "name": "[parameters('storageAccounts_sushdiag140_name')]",
            "apiVersion": "2016-01-01",
            "location": "eastus",
            "tags": {},
            "properties": {},
            "resources": [],
            "dependsOn": []
        },
        {
            "comments": "Generalized from resource: '/subscriptions/7eab3893-bd71-4690-84a5-47624df0b0e5/resourceGroups/sush/providers/Microsoft.Storage/storageAccounts/sushdisks813'.",
            "type": "Microsoft.Storage/storageAccounts",
            "sku": {
                "name": "Premium_LRS",
                "tier": "Premium"
            },
            "kind": "Storage",
            "name": "[parameters('storageAccounts_sushdisks813_name')]",
            "apiVersion": "2016-01-01",
            "location": "eastus",
            "tags": {},
            "properties": {},
            "resources": [],
            "dependsOn": []
        }
    ]
}
