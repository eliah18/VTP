

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
$Quantity=$_POST['quantity'];
$Price=$_POST['price'];
$Deal=$_POST['dealtype'];

if ($Deal=="1"){
	$newsql="select charge from `tbl_dealcharges` where DealType='Sell' ";
	$myquery = $conn->query($newsql);
	while($row = $myquery->fetch_assoc())
	  {
		$Charge=$row['charge'];
	  }
      $dealTotal=$Quantity * ($Price - ($Price *  $Charge));
      echo json_encode(number_format((float)$dealTotal, 2, '.', ''));
  }
  if ($Deal=="2"){
	$newsql="select charge from `tbl_dealcharges` where DealType='Buy' ";
	$myquery = $conn->query($newsql);
	while($row = $myquery->fetch_assoc())
	  {
		$Charge=$row['charge'];
	  }

      $dealTotal=$Quantity * ($Price + ($Price *  $Charge));
      echo json_encode(number_format((float)$dealTotal, 2, '.', ''));
				  }

                
                

?>