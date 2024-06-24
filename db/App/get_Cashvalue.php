<?php
$servername ="localhost";
$username ="root";
$password="";
$dbname="vetdb";

//we will get actions from the app to do operations in the database
$action=$_POST["action"];
$UserID="2";
$CashValue="";
//create connection
$conn = new mysqli($servername,$username,$password,$dbname);

//check connection
if($conn->connect_error){
die("Connection Failed: ". $conn->connect_error);
return;
}

//if the connection is okay


// to get cash value
if("GET_CASH"==$action){
 $newsql="call sp_GetCashValue('$UserID') ";
$myquery = $conn->query($newsql);
while($row = $myquery->fetch_assoc())
    {
        $CashValue = $row['CashValue'];
    }

    echo json_encode($CashValue);
}

?>