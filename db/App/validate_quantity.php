<?php
$servername ="localhost";
$username ="root";
$password="";
$dbname="vetdb";
$price="";
//create connection
$conn = new mysqli($servername,$username,$password,$dbname);

//check connection
if($conn->connect_error){
die("Connection Failed: ". $conn->connect_error);
return;
}
;

  $CounterID = $_POST["counter_id"];
  $Quantity = $_POST["quantity"];
  $schooID ="2";
  $select=mysqli_query($conn,"call sp_GetQuantity($schooID,' $CounterID')");
  while ($row=mysqli_fetch_assoc($select)){
  $OriginalQuantity=$row['Quantity'];
	  
  if ($OriginalQuantity<$Quantity){
	echo "true";
  }
  else{
    echo "false";
  }
	 }

?>