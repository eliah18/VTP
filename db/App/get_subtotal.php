<?php
$servername ="localhost";
$username ="root";
$password="";
$dbname="vetdb";

//create connection
$conn = new mysqli($servername,$username,$password,$dbname);

//check connection
if($conn->connect_error){
die("Connection Failed: ". $conn->connect_error);
return;
}
$Quantity=$_POST['postquantity'];
	$Price=$_POST['postprice'];
	echo ($Quantity * $Price);

    ?>