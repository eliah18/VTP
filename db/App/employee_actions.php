<?php
$servername ="localhost";
$username ="root";
$password="";
$dbname="mydeals";
$table="Employees";


//create connection
$conn = new mysqli($servername,$username,$password,$dbname);

//check connection
if($conn->connect_error){
die("Connection Failed King: ". $conn->connect_error);
return;
}
if(isset($_POST["action"]))
{
                //we will get actions from the app to do operations in the database
            $action=$_POST["action"];


            if("CREATE_TABLE" == $action){
            $sql =  " CREATE TABLE IF NOT EXISTS $table(
                id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                first_name VARCHAR(30) NOT NULL,
                last_name VARCHAR(30) NOT NULL
            
            )";
            
            if($conn->query($sql) === TRUE){
                // send back success message 
                echo "success";
            }
            else{
                echo "error";
            }
            }

            //To get all performance records from the database
            if("GET_ALL"==$action){
                $db_data = array();
                $sql="select id, first_name, last_name from $table ORDER BY id DESC";
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
            // to add deal performed details
            if("ADD_EMP" == $action){
                $first_name = $_POST["first_name"];
                $last_name=$_POST["last_name"];
                $sql="INSERT INTO  $table (first_name, last_name) VALUES ('$first_name','$last_name')";
                $result = $conn->query($sql);
                echo "success";
                $conn->close();
                return;
            }

            if("UPDATE_EMP" == $action){
                $emp_id =$_POST['$emp_id'];
                $first_name = $_POST["first_name"];
                $last_name=$_POST["last_name"];
                $sql=" UPDATE  $table SET first_name= '$first_name', last_name= '$last_name' WHERE id = $emp_id ";
                if($conn->query($sql) === TRUE){
                    echo "success";
                }
                else{
                    echo "error";
                }
                $conn->close();
                return;
            }

            if("DELETE_EMP" == $action){
                $emp_id =$_POST['$emp_id'];
                
                $sql=" DELETE FROM  $table  WHERE id = $emp_id";
                if($conn->query($sql) === TRUE){
                    echo "success";
                }
                else{
                    echo "error";
                }
                $conn->close();
                return;
            }
}

?>