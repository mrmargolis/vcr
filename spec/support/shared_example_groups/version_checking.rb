shared_examples_for "version checking" do |library, options|
  file = options[:file] || "vcr/library_hooks/#{library.downcase}.rb"

  before(:each) do
    # ensure we don't get double callback registration by reloading the file...
    stub_callback_registration if respond_to?(:stub_callback_registration)
  end

  context 'when loading the library hook file', :disable_warnings => true do
    options[:valid].each do |version|
      it "does nothing when #{library}'s version is #{version}" do
        stub_version(version)
        Kernel.should_not_receive(:warn)
        expect { load file }.to_not raise_error
      end
    end

    options[:too_low].each do |version|
      it "raises an error when #{library}'s version is #{version}" do
        stub_version(version)
        Kernel.should_not_receive(:warn)
        expect { load file }.to raise_error(/You are using #{library} #{version}. VCR requires version/)
      end
    end

    options[:too_high].each do |version|
      it "does nothing when #{library}'s version is #{version}" do
        stub_version(version)
        Kernel.should_receive(:warn).with(/VCR is known to work with #{library}/)
        expect { load file }.to_not raise_error
      end
    end
  end
end
