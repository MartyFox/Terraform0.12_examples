locals {

  service_endpoints  = {
    ssm = [
      "AccountA",
      "AccountB",
    ],
    ec2 = [
      "AccountA",
      "AccountB",
      "AccountC"
    ],
    logs = [
      "AccountA",
      "AccountB"
    ],
    ec2messages = [
      "AccountA",
      "AccountC"
    ],
  }

  # Using nested for loops, create a list of objects pairing each service endpoint and account in its list
  # The first for loop gives us the key (endpoint) and the nested for loop gives us the values within the list (accounts)
  endpointaccounts_tuple = flatten([
    for endpoint, accounts in local.service_endpoints : [
      for account in accounts : {
        endpoint = endpoint
        account  = account
      }
    ]
  ])

  # Convert the list tuple from local.endpointaccounts_tuple into a map of maps that can be used in a for_each loop (the below could also be used directly in the for_each )
  # for_each = {
  #   for item in local.endpointaccounts_tuple :
  #   "${item.endpoint}_${item.account}" => item
  # }
  #
  inputs_endpoint_map = {
    for item in local.endpointaccounts_tuple :
    "${item.endpoint}_${item.account}" => item
  }

  # Create a list of tuples with maps pairing each service endpoint and account in its list with a key made up of endpoint-account
  # The first for loop gives us the key (endpoint) and the nested for loop gives us the values within the list (accounts)
  endpointaccounts_tuple_maps = flatten([
    for endpoint, accounts in local.service_endpoints : [
      for account in accounts : {
        "${endpoint}_${account}" = {
        endpoint = endpoint
        account  = account
        }
      }
    ]
  ])

  # Convert the list tuple from local.endpointaccounts_tuple_maps into a map of maps that can be used in a for_each loop (the below could also be used directly in the for_each )
  # for_each = {
  #   for item in local.endpointaccounts_tuple :
  #    keys(item)[0] => values(item)[0]
  # }
  #
  function_endpoint_map = { for item in local.endpointaccounts_tuple_maps: 
    keys(item)[0] => values(item)[0]
  }
  
  # Create a list of distinct (unique) accounts across all maps in local.service_endpoints
  accounts = distinct(flatten([
    for endpoint, accounts in local.service_endpoints : accounts
  ]))
  
  # Search through the list and only return the pairs that contain AccountA
  regex_search = [for pair in local.endpointaccounts_tuple : pair if can(regex("AccountA", pair.account))]


  service_endpoint_list = [
    "ssm",
    "logs",
    "ec2",
    "ec2messages"
  ]

  account_list = [
    "AccountA",
    "AccountB",
    "AccountC",
    "AccountD"
  ]
  
  # Using built in Terraform function "setproduct" combine the 2 lists into all possible variations of endpoint -> account
  endpointaccounts_product = setproduct(local.service_endpoint_list, local.account_list)  

  # Using built in Terraform function "zipmap" combine the 2 lists at their index 0->0, 1->1, 2->2 etc.
  endpointaccounts_map     = zipmap(local.service_endpoint_list, local.account_list)  

  # Using built in Terraform function "lookup" search a map for a string "ec2" and if not found tell us
  endpointaccounts_lookup  = lookup(local.endpointaccounts_map, "ec2", "not found") 
  
  # Using built in Terraform function "keys" extract all keys from the map
  endpointaccounts_keys    = keys(local.endpointaccounts_map) 

  # Using built in Terraform function "contains" this will return false as contains cannot search lists of lists
  contains_search_false = contains(local.endpointaccounts_product, "AccountA") 

  # Using built in Terraform function "contains" this will return true as the list of lists has been flattened
  contains_search_true  = contains(flatten(local.endpointaccounts_product), "AccountA")

}

# The outputs below show how the data is structured or the returned values for each of the locals above

output "list_tuple" {
  value = local.endpointaccounts_tuple
}

output "list_tuple_map" {
  value = local.endpointaccounts_tuple_maps
}

output "maps_of_maps" {
  value = local.function_endpoint_map
}

output "another_maps_of_maps" {
  value = local.inputs_endpoint_map
}

output "unique_account_list" {
  value = local.accounts
}

output "regex_found" {
  value = local.regex_search
}

output "product_list" {
  value = local.endpointaccounts_product
}

output "zipmap" {
  value = local.endpointaccounts_map
}

output "lookups" {
  value = local.endpointaccounts_lookup
}

output "keys" {
  value = local.endpointaccounts_keys
}

output "contains_false" {
  value = local.contains_search_false
}

output "contains_true" {
  value = local.contains_search_true
}
