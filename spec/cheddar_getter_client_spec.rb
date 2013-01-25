require 'spec_helper'
describe Cheddargetter::Client do
  before do 
    class Cheddargetter::Response
      def self.new(response)
        response
      end
    end 
  end

  Username    = 'brent.wooden@gmail.com'
  Password    = 'j3rkface'
  ProductCode = 'BEETLEBOTS'
  UserCodes   = ["T_ROC", "BDOG_RUEZ"]
  PlanCodes    = ["BEETLEBOTS", "SPIDERBOTS"]
  ValidSubscription = {
    :planCode     => PlanCodes.first, 
    :ccFirstName  => 'W Pain', 
    :ccLastName   => "Almeda", 
    :ccNumber     => '4111111111111111',
    :ccExpiration => "04/#{(Date.today.year + 2).to_s}"
  }
  
  CustomerCode  = "W_PAIN"
  ValidCustomer = {
    :customer_code => CustomerCode, 
    :firstName => 'W Pain', 
    :lastName => 'Alemeda', 
    :email => 'w_pain@example.com',  
    :subscription => {:planCode => PlanCodes.last}
  }

  let(:item_code) { "BATTERY" }
  ChargeCode  = 'LATE_FEE'
  
  def create_customer_with_code(code)
    valid_customer = {
      :customer_code => code, 
      :firstName => code.split('_').first.downcase.capitalize, 
      :lastName => code.split('_').last.downcase.capitalize, 
      :email => "#{code.downcase}@example.com",
      :subscription => {:planCode => PlanCodes.last}
    }
    
    cg_client.customers_new(valid_customer)
  end
  
  
  describe 'new' do
    subject { Cheddargetter::Client.new(options) }
    context 'with no username option' do
      let(:options) {{ :password => Password, :product_code => ProductCode }}
      it 'should raise correct arguement error' do
        begin 
          subject 
        rescue Exception => e
          e.to_s.include?("username").should be_true 
        end
      end
    end

    context 'with no password option' do
      let(:options) {{ :username => Username, :product_code => ProductCode }}
      it 'should raise correct arguement error' do
        begin 
          subject 
        rescue Exception => e
          e.to_s.include?("password").should be_true 
        end
      end
    end

    context 'with no product code option' do
      let(:options) {{ :password => Password, :username => Username }}
      it 'should raise correct arguement error' do
        begin 
          subject 
        rescue Exception => e
          e.to_s.include?("product_code").should be_true 
        end
      end
    end

    context 'client actions' do
      let!(:cg_client){ 
        Cheddargetter::Client.new(
          :username     => 'brent.wooden@gmail.com',
          :password     => 'j3rkface',
          :product_code => 'BEETLEBOTS'
        )
      }

      context 'errors' do
        describe 'invalid_method' do
          context 'when invalid controller' do
            subject { cg_client.invalid_method }
            specify { lambda { subject }.should raise_error(NoMethodError) }
          end
          
          context 'when invalid action' do
            subject { cg_client.customers_invalid_method }
            specify { lambda { subject }.should raise_error(NoMethodError) }            
          end
        end
      end
      
      describe 'customers_delete_all' do
        subject { cg_client.customers_delete_all.to_s }
        it { should include('success') }
      end

      context 'create/delete' do
        describe 'customers_new' do
          subject { cg_client.customers_new(ValidCustomer).to_s }
          it { should include('Alemeda') }
        end

        describe 'customers_delete' do
          subject { cg_client.customers_delete(:customer_code => CustomerCode).to_s }
          it { should include 'success' }
        end        
      end
      
      context 'needing existing customers' do
        before { 
          UserCodes.each do |code|
            create_customer_with_code(code)
          end
        }

        describe "customers_get" do
          context "with no arguements get all customers" do
            subject { cg_client.customers_get.to_s }

            UserCodes.each do |user_code|
              it { should include user_code }
            end
          end
        
          context 'with specified customer' do          
            subject { cg_client.customers_get(:customer_code => UserCodes.first).to_s }
            it { should include UserCodes.first }          
            it { should_not include UserCodes.last }
          end
        end
      
        describe 'customers_edit_customer' do
          def reset_customer
            cg_client.customers_edit_customer({:customer_code => UserCodes.first},{:company => ''}).to_s
          end
        
          before  { reset_customer }
          subject { cg_client.customers_edit_customer({:customer_code => UserCodes.first},{:company => 'sbox'}).to_s }
        
          it 'should update customer' do
            should include('sbox')          
          end
        
          it 'should reset customer' do
            reset_customer.should_not include('sbox')        
          end
        end
      end
      
      describe 'customer_edit_subscription' do
        before  { cg_client.customers_new(ValidCustomer) }
        subject { cg_client.customers_edit_subscription({:customer_code => CustomerCode},{:subscription => ValidSubscription}).to_s }
        
        it 'should update subscription' do
          should include(PlanCodes.first)          
        end
        
        describe 'customers_delete' do
          subject { cg_client.customers_delete(:customer_code => CustomerCode).to_s }
          it { should include 'success' }
        end
      end            
      
      describe 'customers_edit' do        
        before  { sleep(8) }
        before  { cg_client.customers_new(ValidCustomer) }
        subject { cg_client.customers_edit({:customer_code => CustomerCode},{:company => 'sbox', :subscription => ValidSubscription}).to_s }
        
        it 'should update subscription' do
          should include(PlanCodes.first)          
        end
        
        it 'should update customer' do
          should include('sbox')
        end        
      end
      
      describe 'customers_delete' do
        subject { cg_client.customers_delete(:customer_code => CustomerCode).to_s }
        it { should include 'success' }
      end

      context 'items' do
        before  { cg_client.customers_new(ValidCustomer) }      

        describe 'customers_add_item_quantity' do
          context 'with a quantity' do
            subject { cg_client.customers_add_item_quantity({:customer_code => CustomerCode, :itemCode => item_code}, {:quantity => 37}).to_s }

            it { should include '37' }
            it { should include item_code }
          end
        end
        
        describe 'set_item_quantity' do
          subject { cg_client.customers_set_item_quantity({:customer_code => CustomerCode, :itemCode => item_code}, {:quantity => 13}).to_s }

          it { should include item_code }
          it { should include '13' }          
        end

        describe 'customers_add_item_quantity()' do
          context 'with no quantity set' do
            subject { cg_client.customers_add_item_quantity({:customer_code => CustomerCode, :itemCode => item_code}).to_s }

            it { should include item_code }
            it { should include '14' }
          end
        end


        describe 'remove_item_quantity' do
          subject { cg_client.customers_remove_item_quantity({:customer_code => CustomerCode, :itemCode => item_code}, {:quantity => 5}).to_s }

          it { should include item_code }
          it { should include '9' }   
          
          describe 'with no quantity set' do
            subject { cg_client.customers_remove_item_quantity({:customer_code => CustomerCode, :itemCode => item_code}).to_s }

            it { should include item_code }
            it { should include '8' }
          end       
        end
        
        describe 'customers_delete' do
          subject { cg_client.customers_delete(:customer_code => CustomerCode).to_s }
          it { should include 'success' }
        end        
      end
      
      describe 'customers_add_charge' do
        before  { cg_client.customers_new(ValidCustomer) }
        subject { cg_client.customers_add_charge({:customer_code => CustomerCode}, {:chargeCode => ChargeCode, :quantity => 1, :eachAmount => 113}).to_s }
        it { should include ChargeCode }
        it { should include '113' }
                
        describe 'customers_delete' do
          subject { cg_client.customers_delete(:customer_code => CustomerCode).to_s }
          it { should include 'success' }
        end            
      end
        
      describe 'customers_delete_charge' do
        before  { 
          cg_client.customers_new(ValidCustomer) 
          cg_client.customers_add_charge({:customer_code => CustomerCode}, {:chargeCode => ChargeCode, :quantity => 1, :eachAmount => 113}).to_s
        }

        subject { cg_client.customers_delete_charge({:customer_code => CustomerCode}, {:chargeId => charge_id}) }

        let(:charge_id) { 
          cg_client.customers_get({:customer_code => CustomerCode}).
          parsed_response["customers"]["customer"]["subscriptions"]["subscription"]["invoices"]["invoice"]["charges"]["charge"].last["id"]
        }
        it { should_not include charge_id }
      end
      
      describe 'invoices_new' do
        before  { cg_client.customers_new(ValidCustomer) }
        subject { cg_client.invoices_new(
          {:customer_code => CustomerCode}, 
          {:charges => {"1" => {:chargeCode => ChargeCode, :quantity => 1, :eachAmount => 117}}}
        ).to_s }
        it { should include ChargeCode }
        it { should include '117' }    
      end  
    end
  end
end