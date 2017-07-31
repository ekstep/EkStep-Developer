<?php

/**
 * This class helps a partner organization integrate with NTP
 *
 * @author G S Bajaj <gourishanker.bajaj@tarento.com>
 * @see https://github.com/project-sunbird/sunbird-commons/wiki/Partner-Organization-and-User-APIs
 */
class Ntp
{
	private $_config;

	public function __construct()
	{
		$this->_config = parse_ini_file('config.ini');
	}

	/**
	 * This function helps create an organization with NTP for a partner
	 *
	 * @param   Array  $data  Array of values needed by the API
	 *
	 * @return  Array         Status and response (optional)
	 */
	public function createOrganization($data)
	{
		$apiUrl = $this->_config['api_base_url'] . $this->_config['api_org_create'];
		$apiBody = '{
				    "request":{
				      "orgName": "' . $data['name'] . '",
				      "description": "' . $data['description'] . '",
				      "externalId":' . $data['id'] . ',
				      "source":"' . $this->_config['provider'] . '"
				    }
				}';

		return $this->exec($apiUrl, $apiBody);
	}

	/**
	 * This function helps update an organization with NTP for a partner
	 *
	 * @param   Array  $data  Array of values needed by the API
	 *
	 * @return  Array         Status and response (optional)
	 */
	public function updateOrganization($data)
	{
		$apiUrl = $this->_config['api_base_url'] . $this->_config['api_org_update'];
		$apiBody = '{
				    "request":{
				      "orgName": "' . $data['name'] . '",
				      "description": "' . $data['description'] . '",
				      "externalId":' . $data['id'] . ',
				      "source":"' . $this->_config['provider'] . '"
				    }
				}';

		return $this->exec($apiUrl, $apiBody);
	}

	/**
	 * This function helps create a user with NTP for a partner
	 *
	 * @param   Array  $data  Array of values needed by the API
	 *
	 * @return  Array         Status and response (optional)
	 */
	public function createUser($data)
	{
		$apiUrl = $this->_config['api_base_url'] . $this->_config['api_user_create'];
		$apiBody = '{
				    "request":{
				      "firstName": "' . $data['fname'] . '",
				      "lastName": "' . $data['lname'] . '",
				      "provider":"' . $this->_config['provider'] . '",
				      "email": "' . $data['email'] . '",
				      "emailVerified":' . $data['emailVerified'] . ',
				      "userName":"' . $data['userName'] . '",
				      "phone": "' . $data['phone'] . '",
					  "phoneNumberVerified":' . $data['phoneVerified'] . '
				    }
				}';

		return $this->exec($apiUrl, $apiBody);
	}

	/**
	 * This function helps update a user with NTP for a partner
	 *
	 * @param   Array  $data  Array of values needed by the API
	 *
	 * @return  Array         Status and response (optional)
	 */
	public function updateUser($data)
	{
		$apiUrl = $this->_config['api_base_url'] . $this->_config['api_user_update'];
		$apiBody = '{
				    "request":{
				      "firstName": "' . $data['fname'] . '",
				      "lastName": "' . $data['lname'] . '",
				      "provider":"' . $this->_config['provider'] . '",
				      "email": "' . $data['email'] . '",
				      "emailVerified":' . $data['emailVerified'] . ',
				      "userName":"' . $data['userName'] . '",
				      "phone": "' . $data['phone'] . '",
					  "phoneNumberVerified":' . $data['phoneVerified'] . '
				    }
				}';

		return $this->exec($apiUrl, $apiBody);
	}

	/**
	 * This function helps associate a user and Organization with NTP for a partner
	 *
	 * @param   Array  $data  Array of values needed by the API
	 *
	 * @return  Array         Status and response (optional)
	 */
	public function addUserToOrganization($data)
	{
		$apiUrl = $this->_config['api_base_url'] . $this->_config['api_user_associate'];
		$apiBody = '{
				    "request":{
				      "externalId": "' . $data['orgId'] . '",
				      "source":"' . $this->_config['provider'] . '",
				      "userName": "' . $data['userName'] . '",
				      "role":' . $data['userRole'] . '
				    }
				}';

		return $this->exec($apiUrl, $apiBody);
	}

	/**
	 * This function helps dis-associate a user and Organization with NTP for a partner
	 *
	 * @param   Array  $data  Array of values needed by the API
	 *
	 * @return  Array         Status and response (optional)
	 */
	public function removeUserFromOrganization($data)
	{
		$apiUrl = $this->_config['api_base_url'] . $this->_config['api_user_disassociate'];
		$apiBody = '{
				    "request":{
				      "externalId": "' . $data['orgId'] . '",
				      "source":"' . $this->_config['provider'] . '",
				      "userName": "' . $data['userName'] . '"
				    }
				}';

		return $this->exec($apiUrl, $apiBody);
	}

	/**
	 * Execute the CURL call to the NTP API
	 *
	 * @param   String  $url      API Endpoint
	 * @param   Array   $data     Array of data required by API
	 * @param   Array   $headers  Array of header. If passed, default headers will be REPLACED by this.
	 *
	 * @return  Array             Status of CURL, response from NTP (if Status is success)
	 */
	protected function exec($url, $data = '', $headers = '')
	{
		// Prepare headers
		$chHeaders = "";
		if ($headers) {
			$chHeaders = $headers;
		} else {
			$chHeaders = array("Content-Type: " . $this->_config['header_content_type'],
								"Authorization: " . $this->_config['header_authorization']);
		}

		// Prepare CURL options
		$chOptions = array(CURLOPT_URL => $url,
				CURLINFO_HEADER_OUT => $this->_config['curl_header_out'],
				CURLOPT_RETURNTRANSFER => $this->_config['curl_returntransfer'],
				CURLOPT_POST => $this->_config['curl_post'],
				CURLOPT_SSL_VERIFYPEER => $this->_config['curl_verify_ssl']);

		if ($chHeaders) {
			$chOptions[CURLOPT_HTTPHEADER] = $chHeaders;
		}

		if ($data) {
			$chOptions[CURLOPT_POSTFIELDS] = $data;
		}

		// Make a call
		$ch = curl_init();
		curl_setopt_array($ch, $chOptions);
		$response = curl_exec($ch);

		// Return
		if (curl_error($ch)) {
			return array('status' => 'error');;
		} else {
			return array('status' => 'success',
						'response' => $response);;
		}

		curl_close($ch);
	}
}
