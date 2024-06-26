
#!/bin/bash

# Delete cloud-init000.iso
virsh vol-delete --pool iso --vol cloud-init000.iso

# Delete cloud-init001.iso
virsh vol-delete --pool iso --vol cloud-init001.iso

# Delete cloud-init002.iso
virsh vol-delete --pool iso --vol cloud-init002.iso

# Delete cloud-init003.iso
virsh vol-delete --pool iso --vol cloud-init003.iso

# Delete cloud-init004.iso
virsh vol-delete --pool iso --vol cloud-init004.iso

# Delete cloud-init004.iso
virsh vol-delete --pool iso --vol cloud-init005.iso

