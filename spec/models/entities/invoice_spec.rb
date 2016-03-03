require 'spec_helper'

describe Entities::Invoice do

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let!(:idmap_sales_order) { create(:idmap, organization: organization, connec_id: 'sales_order_connec_id', connec_entity: 'sales_order', external_id: 'sales_order_external_id', external_entity: 'order') }
    let!(:idmap_item) { create(:idmap, organization: organization, connec_id: 'item_connec_id_id', connec_entity: 'item', external_id: 'item_external_id', external_entity: 'product') }


    subject { Entities::Invoice.new }


    it { expect(subject.connec_entity_name).to eql('invoice') }
    it { expect(subject.external_entity_name).to eql('Transaction') }
    it { expect(subject.mapper_class).to eql(Entities::Invoice::InvoiceMapper) }
    it { expect(subject.object_name_from_connec_entity_hash({'description' => 'the description'})).to eql('the description') }
    it { expect(subject.object_name_from_external_entity_hash({'title' => 'the title'})).to eql('the title') }
    it { expect(subject.get_last_update_date_from_external_entity_hash({'created_at' => Time.new(1985, 9, 17).iso8601})).to eql(Time.new(1985, 9, 17)) }

    describe 'connec_model_to_external_model' do
      let(:organization) { create(:organization) }
      let!(:idmap_sales_order) { create(:idmap, organization: organization, connec_id: 'sales_order_connec_id', connec_entity: 'sales_order', external_id: 'sales_order_external_id', external_entity: 'order') }
      let!(:idmap_item) { create(:idmap, organization: organization, connec_id: 'item_connec_id_id', connec_entity: 'item', external_id: 'item_external_id', external_entity: 'product') }

      let(:connec_hash) {
        {
            sales_order_id: 'sales_order_connec_id',
            transaction_date: Time.new(1985, 9, 17).iso8601,
            type: 'CUSTOMER',
            status: 'PAID',
            lines: [
                {
                    unit_price: {
                        net_amount: 55
                    },
                    quantity: '48',
                    description: 'description',
                    item_id: 'item_connec_id_id'
                }
            ]
        }
      }
      let(:external_hash) {
        {
            order_id: 'sales_order_external_id',
            created_at: Time.new(1985, 9, 17).iso8601,
            financial_status: 'success',
            line_items: [
                {
                    price: 55,
                    quantity: '48',
                    title: 'description',
                    product_id: 'item_external_id'
                }
            ]
        }
      }
      it { expect(subject.map_to_external(connec_hash.deep_stringify_keys, organization)).to eql(external_hash) }
    end

    describe 'external_model_to_connec_model' do


      let(:external_hash) {
        {
            order_id: 'sales_order_external_id',
            created_at: Time.new(1985, 9, 17).iso8601,
            financial_status: 'pending',
            kind: 'refund',
            line_items: [
                {
                    price: 55,
                    quantity: '48',
                    title: 'description',
                    product_id: 'item_external_id'
                }
            ]
        }
      }
      let(:connec_hash) {
        {
            sales_order_id: 'sales_order_connec_id',
            transaction_date: Time.new(1985, 9, 17).iso8601,
            type: 'SUPPLIER',
            status: 'DRAFT',
            lines: [
                {
                    unit_price: {
                        net_amount: 55
                    },
                    quantity: '48',
                    description: 'description',
                    item_id: 'item_connec_id_id'
                }
            ]
        }
      }
      it { expect(subject.map_to_connec(external_hash.deep_stringify_keys, organization)).to eql(connec_hash) }

    end


  end
end