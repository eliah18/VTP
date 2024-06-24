<?php
session_start();
include 'conn.php';
$session = date('Y');

	 /* function clean($str) {
                           $str = @trim($str);
                            if (get_magic_quotes_gpc()) {
                                $str = stripslashes($str);
                            }
                            return mysql_real_escape_string($str);
                        }
											function qoutess($str){
$remove[] = "'";
$remove[] = '"';
$remove[] = "-"; // just as another example 
$new = str_replace($remove, "", $str);
return $new;
} */
if(isset($_POST['btnSubmit'])){
	$username = $_POST["username"];
	$password = $_POST["password"];
	$name = $_POST["name"];
	$surname = $_POST["surname"];
	$email = $_POST["email"];
	 if($username == '' OR $password == ''){
		echo ("<SCRIPT LANGUAGE='JavaScript'> window.alert('Please enter  username or password')
	 javascript:history.go(-1)
		</SCRIPT>");  
	 
	 }
	
	 $sql="call sp_CreateUser('$username',' $password','$name','$surname','$email')";
	 if(mysqli_query($connection,$sql))
	 {
	   echo ("<script> alert('User created Successfully') javascript:history.go(-1)</script>");
		   
			
	 }
	
			
		
			
			
		}
		
	
		
	?>