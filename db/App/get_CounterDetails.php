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


//To get all counter  records from the database
if("GET_COUNTERINFO"==$action){
 
    $db_data = array();
    $sql="call sp_GetCountersTable()";
    $result = $conn->query($sql);
    if($result->num_rows>0){
     while($row = $result-> fetch_assoc()){
        $db_data[]=$row;
     }
     echo json_encode($db_data);
    }

    else{
        echo "error";
    }

    $conn->close();
    return;
}


?>