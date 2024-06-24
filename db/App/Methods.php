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

//To get all transaction records from the database
if("GET_TRANS"==$action){
    $startDate=$_POST['startDate'];
    $endDate=$_POST['endDate'];
    $UserID =$_POST["userid"];
    $db_data = array();
    $sql="call sp_Gettransactionview('$startDate','$endDate',$UserID) ";
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

//To get all portfolio records from the database
if("GET_PORT"==$action){
    $valuedate=$_POST['start'];
    $UserID =$_POST["userid"];
    $db_data = array();
    $sql="call sp_GetPortfolioView($UserID,' $valuedate')";
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

//To get all performance records from the database
if("GET_PERFORM"==$action){
    $valuedate=$_POST['start'];
    $UserID =$_POST["userid"];
    $db_data = array();
    $sql="call sp_ClientPerfomance($UserID,'$valuedate');";
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
if("ADD_DEAL" == $action){
    $Quantity = $_POST["quantity"];
    $CounterName=$_POST["counter"];
    $DealType = $_POST["dealtype"];
    $Price=$_POST["price"];
    $DealTotal =$_POST["dealtotal"];
    $UserID =$_POST["userid"];
    $ActualCash=0;
    $items = array();

    if ($UserID != "")
    {
    
      $sql="call sp_ValidateDealCash('$UserID')";
      if ($select= mysqli_query($conn,$sql))
      {
        do
        {
          if($select != "")
          {
       
            while ($result= mysqli_fetch_assoc($select) )
            {
              
            $items[]=$result;
            }
              
          }
      
      
        }
        
               while(mysqli_next_result($conn));
      }
      
      foreach ($items as $row)
 {
        $ActualCash=$row['CashValue'];
      
        if ( $DealTotal < $ActualCash )
    {
     if($ActualCash != "")
            {
      $sql="call sp_CreateDeal('$UserID',' $CounterName','$DealType','$Quantity','$Price','$DealTotal')";
      if(mysqli_query($conn,$sql))
         {
          $sql1="call sp_UpdateBalance('$UserID','$DealTotal')";
          if(mysqli_query($conn,$sql1))
             {
            echo "success";
               $conn->close();
               return; 
                 
             }
            
             
         }
           }
   }
   else{
    echo "You have insulficient funds to perform this Deal !!!!";
    $conn->close();
    return; 
   }
 }
    }
}
if("LOGIN_CONN" == $action){
    $username = $_POST["username"];
	$password = $_POST["password"];

    if($username == '' OR $password == '')
    {	echo "Please enter the correct username or password";  }
     $sql = "SELECT role_id,SchoolID,username,email,name,surname FROM `systemusers`  WHERE username = '$username' And password='$password'";
			$query = $conn->query($sql);
	
			if($query->num_rows < 1)
      {	echo"Cannot find account with the username"	;}

      while($row = $query->fetch_assoc())
      {
      
            
              date_default_timezone_set('Africa/Harare');
              $time=date("H:i:s");
              $date = date('d-m-Y');
              $query="INSERT INTO `audit_tray`(`username`, `operation` , `date`, `time`) VALUES ('$full','Logged In','$date','$time')";
              if($conn -> query($query)) { echo "success";}
              else {echo "Error: ".$query."<br>".mysqli_error($conn);}
      }
}
?>