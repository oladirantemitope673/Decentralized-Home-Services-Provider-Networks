# Decentralized Home Services Provider Network

A blockchain-based platform for connecting homeowners with verified service providers, built on the Stacks blockchain using Clarity smart contracts.

## Overview

This decentralized application (dApp) provides a trustless platform for home services where:
- Service providers can register and get verified
- Customers can book services with confidence
- Quality is assured through smart contract mechanisms
- Payments are processed securely
- Feedback is collected transparently

## Smart Contracts

### 1. Service Provider Verification (\`service-provider-verification.clar\`)
- Registers new service providers
- Manages verification status
- Tracks provider credentials and specialties

### 2. Booking Management (\`booking-management.clar\`)
- Creates and manages service bookings
- Handles booking status updates
- Manages scheduling and availability

### 3. Quality Assurance (\`quality-assurance.clar\`)
- Defines quality standards
- Manages quality checks and ratings
- Handles dispute resolution

### 4. Payment Processing (\`payment-processing.clar\`)
- Processes secure payments
- Manages escrow functionality
- Handles refunds and disputes

### 5. Customer Feedback (\`customer-feedback.clar\`)
- Collects customer reviews and ratings
- Manages feedback visibility
- Calculates provider reputation scores

## Features

- **Decentralized Verification**: Service providers are verified through a transparent, blockchain-based process
- **Secure Payments**: Escrow-based payment system ensures both parties are protected
- **Quality Assurance**: Built-in quality checks and rating system
- **Transparent Feedback**: All reviews and ratings are stored on-chain
- **Dispute Resolution**: Smart contract-based dispute handling

## Getting Started

### Prerequisites
- Stacks CLI
- Clarinet (for local development)
- Node.js (for running tests)

### Installation

1. Clone the repository
   \`\`\`bash
   git clone <repository-url>
   cd decentralized-home-services
   \`\`\`

2. Install dependencies
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests
   \`\`\`bash
   npm test
   \`\`\`

### Deployment

1. Configure your Stacks network settings
2. Deploy contracts using Clarinet:
   \`\`\`bash
   clarinet deploy
   \`\`\`

## Contract Interactions

### For Service Providers
1. Register using \`register-provider\` function
2. Complete verification process
3. Set availability and services offered
4. Respond to booking requests

### For Customers
1. Browse verified providers
2. Create bookings using \`create-booking\` function
3. Make payments through escrow
4. Leave feedback after service completion

## Testing

The project includes comprehensive tests using Vitest:
\`\`\`bash
npm run test
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Security Considerations

- All contracts include proper access controls
- Payments are held in escrow until service completion
- Provider verification prevents malicious actors
- Dispute resolution mechanisms protect both parties

## Roadmap

- [ ] Mobile app integration
- [ ] Advanced scheduling features
- [ ] Multi-token payment support
- [ ] Insurance integration
- [ ] Advanced analytics dashboard
  \`\`\`
