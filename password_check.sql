-- select a postgresql function pgtle.install_extension with value password_check, 
-- version , description and code block
SELECT
    pgtle.install_extension(
        'password_check',
        '1.0.0',
        'password check function',
 $_pgtle_$
 
 -- Create schema password_check
 CREATE SCHEMA IF NOT EXISTS password_check;
 
 -- Revoke all the permissions from above schema
 REVOKE ALL ON SCHEMA password_check FROM PUBLIC;
 
 -- Grant usage on above schema to public
 GRANT USAGE ON SCHEMA password_check TO PUBLIC;
 
-- Create function passcheck_hook in the above schema which takes 
-- username as text, password as text, password_type as pgtle.password_types, 
-- valid_until timestamptz, valid_null boolean and returns boolean
CREATE OR REPLACE FUNCTION password_check.passcheck_hook(
    username text,
    password text,
    password_type pgtle.password_types,
    valid_until timestamptz,
    valid_null boolean
) RETURNS boolean AS
$$

// create an java script array of commonly used dictionary words such as password admin user
var dictionary = [
    'admin',
    'user',
    'password',
    'pass',
    'administrator',
    'root',
    'superuser',
    'super',
    'manager',
    'manager',
    'administrator']
    
// check if the password exists in the above list if yes return false. 
// Use plv8.elog function with the ERROR and proper description
if (dictionary.indexOf(password) > -1) {
    plv8.elog(ERROR, 'Password is commonly used, please use a different password')
    return false;
    }
    
// check if the password is same as username if yes return false. 
// Use plv8.elog function with the ERROR and proper description
if (password === username) {
    plv8.elog(ERROR, 'Password cannot be same as username')
    return false;
    }
    
// check if password contains at least 1 uppercase character if not return false 
// Use plv8.elog function with the ERROR and proper description
if (password.search(/[A-Z]/) === -1) {
    plv8.elog(ERROR, 'Password must contain at least 1 uppercase character')
    return false;
    }
    
// check if the password contains at least 1 lowercase character
// if not return false 
// Use plv8.elog function with the ERROR and proper description
if (password.search(/[a-z]/) === -1) {
    plv8.elog(ERROR, 'Password must contain at least 1 lowercase character')
    return false;
    }
    
// check if the password contains at least 1 digit
// if not return false 
// Use plv8.elog function with the ERROR and proper description
if (password.search(/[0-9]/) === -1) {
    plv8.elog(ERROR, 'Password must contain at least 1 digit')
    return false;
    }

// check if the password contains at least 8 characters
// if not return false 
// Use plv8.elog function with the ERROR and proper description
if (password.length < 8) {
    plv8.elog(ERROR, 'Password must contain at least 8 characters')
    return false;
    }
    
//close the function with plv8 language
$$ LANGUAGE plv8;

-- Grant execute on the function to public
GRANT EXECUTE ON FUNCTION password_check.passcheck_hook TO PUBLIC;

-- Call the postgresql function pgtle.register_feature with the above in the format "schema.function" and passcheck as feature name
SELECT pgtle.register_feature('password_check.passcheck_hook', 'passcheck');

$_pgtle_$
);
