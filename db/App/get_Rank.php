<?php
$servername ="localhost";
$username ="root";
$password="";
$dbname="vetdb";

//we will get actions from the app to do operations in the database
$action=$_POST["action"];
$UserID="2";
$xul_name="Girls High School";
$Rank="";
//create connection
$conn = new mysqli($servername,$username,$password,$dbname);

//check connection
if($conn->connect_error){
die("Connection Failed: ". $conn->connect_error);
return;
}

//if the connection is okay


// to get Rank
if("GET_RANK"==$action){
	$newsql="call GetRank('$xul_name') ";
	$myquery = $conn->query($newsql);
	while($row = $myquery->fetch_assoc())
		{
			$Rank=$row['ID'];
  
		}

    echo json_encode($Rank);
}

?>