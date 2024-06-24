<?php
$servername ="localhost";
$username ="root";
$password="";
$dbname="vetdb";

//we will get actions from the app to do operations in the database
$action=$_POST["action"];

//create connection
$conn = new mysqli($servername,$username,$password,$dbname);

//check connection
if($conn->connect_error){
die("Connection Failed: ". $conn->connect_error);
return;
}

//if the connection is okay


//To get all login user records from the database
if("LOGIN_CONN" == $action){
    $username = $_POST["username"];
	$password = $_POST["password"];
  $user_data = array();

    if($username == '' OR $password == '')
    {	 }
     $sql = "SELECT SchoolID,username FROM `systemusers`  WHERE username = '$username' And password='$password'";
			$query = $conn->query($sql);
	
			if($query->num_rows < 1)
      {	}

      while($row = $query->fetch_assoc())
      {
        $user_data[]=$row;
       
      }
      echo json_encode($user_data);
}

?>