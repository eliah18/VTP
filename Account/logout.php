<?php 
session_start();
 include "conn.php";
 if(isset($_SESSION['access']) && $_SESSION['fullname'] &&  $_SESSION['access']=="1") { 
     $date = date('d-m-Y');
	 date_default_timezone_set('Africa/Harare');
     $time=date("H:i:s");
	 $query="INSERT INTO `audit_tray`(`username`, `operation` , `date`, `time`) VALUES ('$_SESSION[fullname]','Logged Out','$date','$time')";
		if($connection-> query($query)) { header("location:Index.php");}
		else {echo "Error: ".$query."<br>".mysqli_error($connection);}
	 
unset($_SESSION['username']);
unset($_SESSION['fullname']);


session_unset();
session_destroy();

header("location:Index.php");
 }
else{header('location:../Account/Index.php');} ?>