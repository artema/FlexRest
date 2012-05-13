package flexUnitTests
{
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.http.OAuthHeader;
	import mx.rpc.http.OAuthSerializationFilter;
	import mx.rpc.http.Operation;
	import mx.utils.JSONUtil;
	
	import org.flexunit.Assert;
	
	public class OAuthSerializationFilterTest
	{		
		//--------------------------------------------------------------------------
		//
		//  Data
		//
		//--------------------------------------------------------------------------
		
		private var filter:OAuthSerializationFilter;
		private var operation:Operation;
		private var request:Object;
		
		//--------------------------------------------------------------------------
		//
		//  Lifecycle
		//
		//--------------------------------------------------------------------------
		
		[Before]
		public function setUp():void
		{
			var oauthData:OAuthHeader = new OAuthHeader();
			oauthData.oauth_version = "1.0";
			oauthData.oauth_consumer_key = "xvz1evFS4wEEPTGEFPHBog";
			oauthData.oauth_token = "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb";
			oauthData.oauth_nonce = "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg";
			oauthData.oauth_signature_method = OAuthHeader.SIGNATURE_METHOD_HMAC_SHA1;
			oauthData.oauth_timestamp = 1318622958;
			
			filter = new OAuthSerializationFilter();
			filter.oauthData = oauthData;
			filter.keySecret = "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw";
			filter.tokenSecret = "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE";

			operation = new Operation();
			operation.method = HTTPRequestMessage.GET_METHOD;
			operation.contentType = "application/json";
			operation.url = "http://api.example.com/service";
			
			request = {};
		}
		
		//--------------------------------------------------------------------------
		//
		//  Test methods
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function testEmpty():void
		{
			try
			{
				filter.serializeBody(operation, request);
			}
			catch(e:Error)
			{
				Assert.fail("An exception was thrown: " + e.message.toString());				
				return;
			}
			
			Assert.assertTrue(true);
		}
		
		[Test]
		public function testFormContent():void
		{
			operation.method = HTTPRequestMessage.POST_METHOD;
			operation.contentType = HTTPRequestMessage.CONTENT_TYPE_FORM;
			operation.url = "https://api.twitter.com/1/statuses/update.json?include_entities=true";
			
			request = {
				status: "Hello Ladies + Gentlemen, a signed OAuth request!"
			};
			
			filter.serializeBody(operation, request);
			
			var header:String = String(operation.headers["Authorization"]);
			const validHeader:String = 'OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog", oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg", ' + 
				'oauth_signature="ZjEyNDE5MjhmOTYwMjQyZWEyN2U5OTM1Nzk4NzcxNjc%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1318622958", ' + 
				'oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb", oauth_version="1.0"';			
			
			Assert.assertEquals(validHeader, header);
		}
		
		[Test]
		public function testJsonContent():void
		{
			operation.method = HTTPRequestMessage.POST_METHOD;

			request = '{"key":"value"}';
			
			filter.serializeBody(operation, request);
			
			var header:String = String(operation.headers["Authorization"]);
			const validHeader:String = 'OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog", oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg", ' + 
				'oauth_signature="MmI3ODdlNjU3ZTA5YWViNGRhMTNlYWE5MTVjOTI5ZDI%3D", oauth_signature_method="HMAC-SHA1", ' + 
				'oauth_timestamp="1318622958", oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb", oauth_version="1.0", ' + 
				'oauth_body_hash="NDNjMGJhMzRjYmZiYTQyNTUyNDE1ZmI2ZjQ5YjEzNGM%3D"';
			
			Assert.assertEquals(validHeader, header);
		}
	}
}