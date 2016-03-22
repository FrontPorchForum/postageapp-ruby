require File.expand_path('helper', File.dirname(__FILE__))

class Mailer2Test < MiniTest::Test
  require_action_mailer(2) do
    require File.expand_path('mailer/action_mailer_2/notifier', File.dirname(__FILE__))

    puts "\e[0m\e[32mRunning #{File.basename(__FILE__)} for action_mailer #{ActionMailer::VERSION::STRING}\e[0m"
        
    def test_create_blank
      assert mail = Notifier.create_blank

      assert_equal 'send_message', mail.method
      assert_equal 'https://api.postageapp.com/v.1.0/send_message.json', mail.url.to_s
      assert mail.arguments.blank?
    end
    
    def test_create_with_no_content
      assert mail = Notifier.create_with_no_content

      assert_equal 'recipient@example.net', mail.arguments['recipients']
      assert_equal({ 'from' => 'sender@example.com', 'subject' => 'Test Email' }, mail.arguments['headers'])
      assert mail.arguments['content'].blank?
    end
    
    def test_create_with_text_only_view
      assert mail = Notifier.create_with_text_only_view

      assert_equal 'text only: plain text', mail.arguments['content']['text/plain']
    end
    
    def test_create_with_html_and_text_views
      assert mail = Notifier.create_with_html_and_text_views

      assert_equal 'html and text: plain text', mail.arguments['content']['text/plain']
      assert_equal 'html and text: html', mail.arguments['content']['text/html']
    end
    
    def test_deliver_with_html_and_text_views
      mock_successful_send
      
      assert response = Notifier.deliver_with_html_and_text_views

      assert response.is_a?(PostageApp::Response)
      assert response.ok?
    end
    
    def test_create_with_simple_view
      assert mail = Notifier.create_with_simple_view
      assert_equal 'simple view content', mail.arguments['content']['text/plain']
    end
    
    def test_create_with_manual_parts
      assert mail = Notifier.create_with_manual_parts

      assert_equal 'text content', mail.arguments['content']['text/plain']
      assert_equal 'html content', mail.arguments['content']['text/html']
      assert !mail.arguments['attachments'].blank?
      assert !mail.arguments['attachments']['foo.jpg']['content'].blank?
      assert_equal 'image/jpeg', mail.arguments['attachments']['foo.jpg']['content_type']
    end
    
    def test_create_with_body_and_attachment
      assert mail = Notifier.create_with_body_and_attachment

      assert !mail.arguments['content'].blank?
      assert !mail.arguments['content']['text/plain'].blank?
      assert_equal 'body text', mail.arguments['content']['text/plain']
      assert !mail.arguments['attachments'].blank?
      assert !mail.arguments['attachments']['foo.jpg']['content'].blank?
      assert_equal 'image/jpeg', mail.arguments['attachments']['foo.jpg']['content_type']
    end
    
    def test_create_with_custom_postage_variables
      assert mail = Notifier.create_with_custom_postage_variables

      assert_equal 'custom_uid', mail.uid
      assert_equal 'custom_api_key', mail.api_key
      assert_equal 'test-template', mail.arguments['template']
      assert_equal({ 'variable' => 'value' }, mail.arguments['variables'])
      assert_equal({ 'test2@example.net' => { 'name' => 'Test 2'}, 
                      'test1@example.net' => { 'name' => 'Test 1'}}, mail.arguments['recipients'])
      assert_equal 'text content', mail.arguments['content']['text/plain']
      assert_equal 'html content', mail.arguments['content']['text/html']
    end
    
    def test_create_with_recipient_override
      PostageApp.configuration.recipient_override = 'override@example.net'

      assert mail = Notifier.create_with_html_and_text_views

      assert_equal 'recipient@example.net', mail.arguments['recipients']
      assert_equal 'override@example.net', mail.arguments_to_send['arguments']['recipient_override']
    end
  end
end
