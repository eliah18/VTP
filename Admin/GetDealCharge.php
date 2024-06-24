<?php
include("conn.php"); 
//error_reporting(0);
ob_start();
session_start(); 
if(isset($_SESSION['access']) && $_SESSION['fullname']  &&  $_SESSION['access']=="1") {
  if(isset($_POST['postid'])){
   $ID = $_POST["postid"];

    
    $sql="select Charge from tbl_DealCharges where DealChargesID='$ID'";
    $myquery = $connection->query($sql);
		while($row = $myquery->fetch_assoc())
		  {
			$Charge=$row['Charge'];
		  }
      echo $Charge ;
   }  

}

?>