<?php
include("conn.php"); 
//error_reporting(0);
ob_start();
session_start(); 
if(isset($_SESSION['access']) && $_SESSION['fullname']  &&  $_SESSION['access']=="1") {
  if(isset($_POST['postid'])){
   $ID = $_POST["postid"];
 
    
    $sql="delete from tbl_DealCharges where DealChargesID='$ID'";
    if(mysqli_query($connection,$sql))
    {
      echo ("Deal charge has been deleted Successfully'");
          
           
    }
   }  

}

?>