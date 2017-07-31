<?php

require_once 'ntp/ntp.php';

/************* Create user *************/
/*$data = array('fname' => 'A V S S SUBBA',
    				'email' => 'gsbajaj@apschooledu.in',
    				'emailVerified' => 'true',
    				'userName' => '9341229258',
    				'phone' => '9341229258',
    				'phoneVerified' => 'true',
				  );

$ntp = new Ntp();
$resp = $ntp->createUser($data);

echo "<pre>";
var_dump($resp);
echo "</pre>";*/


/*
ERROR RESPONSE
array(2) {
  ["status"]=>
  string(7) "success"
  ["response"]=>
  string(327) "{"id":"api.user.create","ver":"v1","ts":"2017-07-31 04:42:15:103+0000","params":{"resmsgid":null,"msgid":"13cb6a7e-16fa-44ec-9634-6a1d9abc112f","err":"USERNAME_EMAIL_IN_USE","status":"USERNAME_EMAIL_IN_USE","errmsg":"Username is already in use. Please try with a different username."},"responseCode":"CLIENT_ERROR","result":{}}"
}

SUCCESS RESPONSE
array(2) {
  ["status"]=>
  string(7) "success"
  ["response"]=>
  string(255) "{"id":"api.user.create","ver":"v1","ts":"2017-07-31 04:44:08:598+0000","params":{"resmsgid":null,"msgid":null,"err":null,"status":"success","errmsg":null},"responseCode":"OK","result":{"response":"SUCCESS","userId":"44291d87-e964-40d7-84a1-8498f92f0ec2"}}"
}
*/

/************* Get JWT Token *************/

// $data = array('name' => 'A V S S SUBBA',
//             'email' => 'gsbajaj@apschooledu.in',
//             'emailVerified' => 'true',
//             'userName' => '9341229258',
//             'phone' => '9341229258',
//             'phoneVerified' => 'true',
//           );

// $ntp = new Ntp();
// $resp = $ntp->getToken($data);

// echo "<pre>";
// var_dump($resp);
// echo "</pre>";