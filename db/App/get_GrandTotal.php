<?php
$servername ="localhost";
$username ="root";
$password="";
$dbname="vetdb";

//we will get actions from the app to do operations in the database
$action=$_POST["action"];
$UserID="2";
$GrandTotal="";
//create connection
$conn = new mysqli($servername,$username,$password,$dbname);

//check connection
if($conn->connect_error){
die("Connection Failed: ". $conn->connect_error);
return;
}

//if the connection is okay


// to get Grand Total
if("GET_GRAND"==$action){
$newsql="call sp_GetPortfolioValue('$UserID') ";
$myquery = $conn->query($newsql);
while($row = $myquery->fetch_assoc())
    {
        $GrandTotal =$row['PortfolioValue'];

    }

    echo json_encode($GrandTotal);
}

?>