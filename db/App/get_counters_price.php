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
if(isset($_POST["action"]))
{
  $action=$_POST["action"];

if("GET_PRICE" == $action){
  $CounterID = $_POST["counter_id"];
  $Countername ="";
  $sql="select ShortName  from Counters where CounterID='$CounterID'";
  $myquery = $conn->query($sql);
	while($row = $myquery->fetch_assoc())
		{
			$Countername=$row['ShortName'];
     
		}
    
   if($Countername != ""){
    $sql="Select Price from `counterprices` where ShortName='$Countername'";
    $myquery = $conn->query($sql);
    while($row = $myquery->fetch_assoc())
      {
        $price=$row['Price'];
       
      }
      echo json_encode($price);
   }

  
}
}

?>