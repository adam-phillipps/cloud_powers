module Smash
  module CloudPowers
    module AwsStubs
      INSTANCE_METADATA_STUB = {
        'ami-id' => 'ami-1234',
        'ami-launch-index' => '1',
        'ami-manifest-path' => '',
        'block-device-mapping/' => '',
        'hostname' => '',
        'instance-action' => '',
        'instance-id' => 'asd-1234',
        'instance-type' => 't2.nano',
        'kernel-id' => '',
        'local-hostname' => 'ip-10-251-50-12.ec2.internal',
        'local-ipv4' => '',
        'mac network/' => '',
        'placement/' => 'boogers',
        'public-hostname' => 'ec2-203-0-113-25.compute-1.amazonaws.com',
        'public-ipv4' => 'adsfasdfasfd',
        'public-keys/' => 'jfakdsjfkdlsajfkldsajflkasjdfklajsdflkajsldkfjalsdfjaklsdjflasjfklasjdfkals',
        'public-keys/0' => 'asdjfkasdjfkasdjflasjdfklsajdlkfjaldkgfjalkdfgjklsdfjgklsdjfklsjlkdfjakdlfjalskdfjlas',
        'reservation-id' => 'r-fea54097',
        'security-groups' => 'groupidygroupgroupgroup',
        'services/' => ''
      }

      NEURON_STUB = {
        stub_responses: {
          run_instances: {
            instances: [
              { instance_id: 'asd-1234', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'qwe-4323', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'tee-4322', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'bbf-6969', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'lkj-0987', launch_time: Time.now, state: { name: 'running' } },
          ]},
          describe_instances: {
            reservations: [
              { instances: [
                { instance_id: 'asd-1234', state: { code: 200, name: 'running' } },
                { instance_id: 'qwe-4323', state: { code: 200, name: 'running' } },
                { instance_id: 'tee-4322', state: { code: 200, name: 'running' } },
                { instance_id: 'bbf-6969', state: { code: 200, name: 'running' } },
                { instance_id: 'lkj-0987', state: { code: 200, name: 'running' } }
          ] }] },
          describe_images: {
            images: [
              { image_id: 'asdf', state: 'available' },
              { image_id: 'fdas', state: 'available' },
              { image_id: 'fdadg', state: 'available' },
              { image_id: 'aswre', state: 'available' },
              { image_id: 'fsnkv', state: 'available' },
            ]
          }
        }
      }
    end
  end
end
