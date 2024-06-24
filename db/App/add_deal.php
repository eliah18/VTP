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


// to add deal performed details
if("ADD_DEAL" == $action){
    $Quantity = $_POST["quantity"];
    $CounterName=$_POST["counter"];
    $DealType = $_POST["dealtype"];
    $Price=$_POST["price"];
    $DealTotal =$_POST["dealtotal"];
    $UserID ='2';
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


?>