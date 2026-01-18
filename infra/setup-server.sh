#!/bin/bash
# PixPos Remote Server Setup Script
# This script sets up a RustDesk server on AWS EC2

set -e

echo "🚀 PixPos Remote Server Kurulumu Başlıyor..."

# Variables
INSTANCE_TYPE="t3.micro"
AMI_ID="ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS us-east-1
REGION="us-east-1"
KEY_NAME="pixpos-remote-key"
SECURITY_GROUP_NAME="pixpos-remote-sg"

# Check if key pair exists, if not create it
if ! aws ec2 describe-key-pairs --key-names $KEY_NAME --region $REGION 2>/dev/null; then
    echo "📝 SSH Key oluşturuluyor..."
    aws ec2 create-key-pair --key-name $KEY_NAME --region $REGION --query 'KeyMaterial' --output text > ~/.ssh/$KEY_NAME.pem
    chmod 400 ~/.ssh/$KEY_NAME.pem
    echo "✅ SSH Key oluşturuldu: ~/.ssh/$KEY_NAME.pem"
fi

# Create security group if not exists
SG_ID=$(aws ec2 describe-security-groups --group-names $SECURITY_GROUP_NAME --region $REGION --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || echo "")

if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ]; then
    echo "🔒 Security Group oluşturuluyor..."
    SG_ID=$(aws ec2 create-security-group \
        --group-name $SECURITY_GROUP_NAME \
        --description "PixPos Remote Server Security Group" \
        --region $REGION \
        --query 'GroupId' --output text)
    
    # Add rules for RustDesk
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 21115 --cidr 0.0.0.0/0 --region $REGION
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 21116 --cidr 0.0.0.0/0 --region $REGION
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol udp --port 21116 --cidr 0.0.0.0/0 --region $REGION
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 21117 --cidr 0.0.0.0/0 --region $REGION
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 21118 --cidr 0.0.0.0/0 --region $REGION
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 21119 --cidr 0.0.0.0/0 --region $REGION
    echo "✅ Security Group oluşturuldu: $SG_ID"
fi

# User data script for EC2
USER_DATA=$(cat <<'EOF'
#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

mkdir -p /opt/rustdesk
cd /opt/rustdesk

# Run RustDesk Server
docker run -d --name hbbs --restart always \
    -p 21115:21115 -p 21116:21116 -p 21116:21116/udp -p 21118:21118 \
    -v /opt/rustdesk:/root \
    rustdesk/rustdesk-server hbbs

docker run -d --name hbbr --restart always \
    -p 21117:21117 -p 21119:21119 \
    -v /opt/rustdesk:/root \
    rustdesk/rustdesk-server hbbr

# Wait for key generation
sleep 10
cat /opt/rustdesk/id_ed25519.pub > /opt/rustdesk/public_key.txt
EOF
)

echo "🖥️  EC2 Instance başlatılıyor..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --user-data "$USER_DATA" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=PixPos-Remote-Server}]" \
    --region $REGION \
    --query 'Instances[0].InstanceId' --output text)

echo "⏳ Instance başlatılıyor... ($INSTANCE_ID)"
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo ""
echo "============================================"
echo "✅ PixPos Remote Server Kuruldu!"
echo "============================================"
echo ""
echo "📍 Server IP: $PUBLIC_IP"
echo "🔑 Instance ID: $INSTANCE_ID"
echo ""
echo "⏳ Docker kurulumu tamamlanması için 2-3 dakika bekleyin."
echo ""
echo "Public key almak için:"
echo "  ssh -i ~/.ssh/$KEY_NAME.pem ubuntu@$PUBLIC_IP 'cat /opt/rustdesk/id_ed25519.pub'"
echo ""
echo "Uygulamada kullanmak için:"
echo "  ID Server: $PUBLIC_IP"
echo "============================================"

# Save server info
echo "$PUBLIC_IP" > server_ip.txt
echo "$INSTANCE_ID" > instance_id.txt
