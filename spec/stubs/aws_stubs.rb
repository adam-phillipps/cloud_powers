module Smash
  module CloudPowers
    module SpecConfig
      INSTANCE_METADATA_KEYS = {
        'ami-id' => ,
        'ami-launch-index' => ,
        'ami-manifest-path' => ,
        'block-device-mapping/' => ,
        'hostname' => ,
        'instance-action' => ,
        'instance-id',
        'instance-type',
        'kernel-id',
        'local-hostname',
        'local-ipv4',
        'mac network/',
        'placement/',
        'public-hostname',
        'public-ipv4',
        'public-keys/',
        'reservation-id',
        'security-groups',
        'services/'
      }
      SPIN_UP_NEURONS = {
        stub_responses: {
          run_instances: {
            instances: [
              { instance_id: 'asd-1234', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'qwe-4323', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'tee-4322', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'bbf-6969', launch_time: Time.now, state: { name: 'running' } },
              { instance_id: 'lkj-0987', launch_time: Time.now, state: { name: 'running' } },
            ]
          },
          describe_instances: {
            reservations: [{ instances: [{ instance_id: 'asd-1234', state: { code: 200, name: 'running' } },
                              { instance_id: 'qwe-4323', state: { code: 200, name: 'running' } },
                              { instance_id: 'tee-4322', state: { code: 200, name: 'running' } },
                              { instance_id: 'bbf-6969', state: { code: 200, name: 'running' } },
                              { instance_id: 'lkj-0987', state: { code: 200, name: 'running' } }]}]},
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
