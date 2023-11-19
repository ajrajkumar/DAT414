-- select a postgresql function pgtle.install_extension with value password_check, 
-- version , description and code block

$_pgtle_$
 
 -- Create schema password_check
 
 -- Revoke all the permissions from above schema
 
 -- Grant usage on above schema to public
 
-- Create function passcheck_hook in the above schema which takes 
-- username as text, password as text, password_type as pgtle.password_types, 
-- valid_until timestamptz, valid_null boolean and returns boolean

// create an java script array of commonly used dictionary words such as password admin user
    
// check if the password exists in the above list if yes return false. 
// Use plv8.elog function with ERROR and proper description
    
// check if the password is same as username if yes return false. 
    
// check if password contains at least 1 uppercase character if not return false 
    
// check if the password contains at least 1 lowercase character
    
// check if the password contains at least 1 digit

// check if the password contains at least 8 characters
    
//close the function with plv8 language

-- Grant execute on the function to public

-- Call the postgresql function pgtle.register_feature with the above in the format "schema.function" and passcheck as feature name

$_pgtle_$
);
