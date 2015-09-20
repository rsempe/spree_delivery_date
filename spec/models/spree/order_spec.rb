require 'spec_helper'

describe Spree::Order do
  describe "#set_default_delivery_date" do
    before { allow(Time).to receive(:now) { time } }
    let(:time) { Time.new(2010, 1, 15, 12) }

    context "when cutoff date is past" do
      before do
        allow_any_instance_of(Time).to receive(:past?) { true }
      end

      context "when the day after tomorrow is sunday" do
        before do
          allow_any_instance_of(ActiveSupport::TimeWithZone).to receive(:wday) { 0 }
        end

        it "returns 3 days from now" do
          expect(subject.delivery_date).to eq(Date.new(2010, 1, 18))
        end
      end

      context "when the day after tomorrow is not sunday" do
        before do
          allow_any_instance_of(ActiveSupport::TimeWithZone).to receive(:wday) { 1 }
        end

        it "returns the day after tomorrow" do
          expect(subject.delivery_date).to eq(Date.new(2010, 1, 17))
        end
      end
    end

    context "when cutoff date is not past" do
      before do
        allow_any_instance_of(Time).to receive(:past?) { false }
      end

      context "when tomorrow is sunday" do
        before do
          allow_any_instance_of(ActiveSupport::TimeWithZone).to receive(:wday) { 0 }
        end

        it "returns the day after tomorrow" do
          expect(subject.delivery_date).to eq(Date.new(2010, 1, 17))
        end
      end

      context "when tomorrow is not sunday" do
        before do
          allow_any_instance_of(ActiveSupport::TimeWithZone).to receive(:wday) { 1 }
        end

        it "returns tomorrow" do
          expect(subject.delivery_date).to eq(Date.new(2010, 1, 16))
        end
      end
    end
  end

  describe "#delivery_date_present" do
    before { subject.state = "confirm" }

    context "whithout a delivery_date" do
      it "adds an error to delivery_date field" do
        subject.delivery_date = nil
        subject.valid?
        expect(subject.errors[:delivery_date].size).to eq(1)
      end
    end

    context "with a delivery_date" do
      it "doesn't add any error" do
        subject.valid?
        expect(subject.errors[:delivery_date].size).to eq(0)
      end
    end
  end

  describe "#delivery_date_specific_validation" do
    before do
      allow(Date).to receive(:current) { Date.new(2010, 1, 15) }
      subject.state = "confirm"
    end

    context "when delivery date is sunday" do
      it "adds an error to delivery_date field" do
        subject.delivery_date = Date.new(2010, 1, 17)
        subject.valid?
        expect(subject.errors[:delivery_date].size).to eq(1)
      end
    end

    context "when it's too late for delivery" do
      it "adds an error to delivery_date field" do
        subject.delivery_date = Date.new(2010, 1, 16)
        subject.valid?
        expect(subject.errors[:delivery_date].size).to eq(1)
      end
    end
  end
end
