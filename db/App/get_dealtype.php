
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

$counter = mysqli_query($conn,"select DealTypeID as ID, DealType from dealtypes");
$list = array();

while ($rowdata = $counter -> fetch_assoc()){
  $list[]= $rowdata;
}

echo json_encode($list);

?>