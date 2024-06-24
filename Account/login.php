<?php
session_start();
include 'conn.php';
$session = date('Y');

	 /* function clean($str) {
                           $str = @trim($str);
                            if (get_magic_quotes_gpc()) {
                                $str = stripslashes($str);
                            }
                            return mysql_real_escape_string($str);
                        }
											function qoutess($str){
$remove[] = "'";
$remove[] = '"';
$remove[] = "-"; // just as another example 
$new = str_replace($remove, "", $str);
return $new;
} */
if(isset($_POST['btnSubmit'])){
	$username = $_POST["username"];
	$password = $_POST["password"];
	 if($username == '' OR $password == ''){
		echo ("<SCRIPT LANGUAGE='JavaScript'> window.alert('Please enter the correct username or password')
	 javascript:history.go(-1)
		</SCRIPT>");  
	 
	 }
	
	$sql = "SELECT * FROM `systemusers`  WHERE username = '$username' And password='$password'";
			$query = $connection->query($sql);
	
			if($query->num_rows < 1){
				echo("<SCRIPT LANGUAGE='JavaScript'> window.alert('Cannot find account with the username')
				javascript:history.go(-1)
				 </SCRIPT>"); 
			
			}
			else{
				while($row = $query->fetch_assoc())
				{
				
					$access=$row['role_id'];
					$UserID=$row['SchoolID'];
					$username=$row['username'];
					$sessionid=$rows['SchoolID'];
					$email=$rows['email'];
					
					$q1=$row['name'];
					$q2=$row['surname'];
					$full=$q1." ".$q2;
					$_SESSION['fullname']=$q1." ".$q2;
					$_SESSION['UserID'] = $UserID;
					$_SESSION['id'] = $sessionid;
	if($access=="1")
	 { 
		
					$_SESSION['email']=$email;
					$_SESSION['fullname'] = $full;
					$_SESSION['access'] = $access;
					$_SESSION['username'] = $username;
					date_default_timezone_set('Africa/Harare');
					$time=date("H:i:s");
					$date = date('d-m-Y');
					$query="INSERT INTO `audit_tray`(`username`, `operation` , `date`, `time`) VALUES ('$full','Logged In','$date','$time')";
					if($connection-> query($query)) { header("location:../admin/StartupCash.php");}
					else {echo "Error: ".$query."<br>".mysqli_error($connection);}
	 }
	 else if($access=="2")
	 {  
					$_SESSION['UserID'] = $UserID;
					$_SESSION['email']=$email;
					$_SESSION['fullname'] = $full;
					$_SESSION['access'] = $access;
					$_SESSION['username'] = $username;
					date_default_timezone_set('Africa/Harare');
					$time=date("H:i:s");
					$date = date('d-m-Y');
					$query="INSERT INTO `audit_tray`(`username`, `operation` , `date`, `time`) VALUES ('$full','Logged In','$date','$time')";
					if($connection-> query($query)) { header("location:../pages/dashboard.php");}
					else {echo "Error: ".$query."<br>".mysqli_error($connection);}
					
					
				
		 
	 }
	 else if($access=="3")
	 {
					$_SESSION['UserID'] = $UserID;
					$_SESSION['email']=$email;
					$_SESSION['fullname'] = $full;
					$_SESSION['access'] = $access;
					$_SESSION['username'] = $username;
					date_default_timezone_set('Africa/Harare');
					$time=date("H:i:s");
					$date = date('d-m-Y');
					$query="INSERT INTO `audit_tray`(`username`, `operation` , `date`, `time`) VALUES ('$full','Logged In','$date','$time')";
					if($connection-> query($query)) { header("location:Senior/index.php");}
					else {echo "Error: ".$query."<br>".mysqli_error($connection);}
					
		
	
		 
	 }


			$newsql="Select SchoolName from `schools` where SchoolID='$UserID' ";
			$myquery = $connection->query($newsql);
			while($row = $myquery->fetch_assoc())
				{
					$_SESSION['SchoolName']=$row['SchoolName'];
				}
				}
			
			}
			
			
		}
		
	
		
	?>