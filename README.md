This project borrows highly from cheddargetter_client_ruby.
I completely reuse their response object.

I felt however their implementation of calls to the Cheddargetter api were too static,
so I implemented a wrapper using method missing.  This way if methods
are added to the api, they can be easily accessed.  Here are some mappings. 
There should be a noticable pattern.


-    #/customers/get                 
--   cg_client_object.customers_get({:customer_code => 'ABCD'}) (code optional)
-    #/customers/new                 
--   cg_client_object.customers_new({
    :customer_code => CustomerCode, 
    :firstName => 'W Pain', 
    :lastName => 'Alemeda', 
    :email => 'w_pain@example.com',  
    :subscription => {:planCode => PlanCodes.last}
  })

-    #/customers/edit
-- cg_client.customers_edit({:customer_code => 'ABCD'}, *valid_customer_attributes_hash*)    
-    #/customers/edit-customer       
-- cg_client.customers_edit_customer({:customer_code => 'ABCD'}, *valid_customer_attributes_hash*) 
-    #/customers/edit-subscription      
-- cg_client.customers_edit_subscription({:customer_code => 'ABCD'}, {:subscription => *ValidSubscription*}) 
-    #/customers/delete         
-- cg_client.customers_delete({:customer_code => 'ABCD'})    
-    #/customers/cancel               
-- cg_client.customers_cancel({:customer_code => 'ABCD'})    
-    #/customers/add-item-quantity  
-- cg_client.customers_add_item_quantity({:customer_code => CustomerCode, :itemCode => item_code} 
-    #/customers/remove-item-quantity  
-- cg_client.customers_remove_item_quantity({:customer_code => CustomerCode, :itemCode => item_code}, {:quantity => 5})
-    #/customers/set-item-quantity   
  cg_client.customers_set_item_quantity({:customer_code => CustomerCode, :itemCode => item_code}, {:quantity => 13}

See the specs more examples. These are copied from them.
