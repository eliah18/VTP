<?php
include("conn.php"); 
//error_reporting(0);
ob_start();
session_start(); 
if(isset($_SESSION['access']) && $_SESSION['fullname']  &&  $_SESSION['access']=="1") {
  if(isset($_POST['postid'])){
   $ID = $_POST["postid"];
 
    
    $sql="delete from  schoolstartupcash where `ID`='$ID'";
    if(mysqli_query($connection,$sql))
    {
      echo ("School startup Amount has been deleted Successfully'");
          
           
    }
   }  

}

?>