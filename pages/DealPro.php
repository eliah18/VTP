<?php
include("conn.php");
//error_reporting(0);
ob_start();
session_start(); 
if(isset($_POST['postquantity']) && isset($_POST['postprice']) && isset($_POST['postdealtype'])&& isset($_POST['postcounter']) && isset($_POST['postdealtotal'])  &&  isset($_SESSION['access']) && $_SESSION['fullname'] && $_SESSION['UserID'] &&  $_SESSION['access']=="2")
	{
    $Quantity = $_POST["postquantity"];
    $CounterName=$_POST["postcounter"];
    $DealType = $_POST["postdealtype"];
    $Price=$_POST["postprice"];
    $DealTotal =$_POST["postdealtotal"];
    $UserID =$_SESSION['UserID'];
    $ActualCash=0;
    $items = array();
  
    if ($UserID != "")
    {
    
      $sql="call sp_ValidateDealCash('$UserID')";
      if ($select= mysqli_query($connection,$sql))
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
        
               while(mysqli_next_result($connection));
      }
      
      foreach ($items as $row)
 {
        $ActualCash=$row['CashValue'];
      
        if ( $DealTotal < $ActualCash )
    {
     if($ActualCash != "")
            {
      $sql="call sp_CreateDeal('$UserID',' $CounterName','$DealType','$Quantity','$Price','$DealTotal')";
      if(mysqli_query($connection,$sql))
         {
          $sql1="call sp_UpdateBalance('$UserID','$DealTotal')";
          if(mysqli_query($connection,$sql1))
             {
            echo "success";
                
                 
             }
            
             
         }
           }
   }
   else{
    echo ("<script> alert('You have insulficient funds to perform this Deal !!!!');window.location='Deal.php';</script>");
   }
 }
    }
 
    //echo ("<script> alert('$ActualCash');window.location='Deal.php';</script>");
  
  
	}
	
?>