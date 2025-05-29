# FitnessChallenge Arena

A decentralized fitness challenge platform built on the Stacks blockchain that connects personal trainers with fitness enthusiasts through structured workout challenges.

## Overview

FitnessChallenge Arena empowers personal trainers to create monetized fitness challenges while providing participants with structured workout programs and progress tracking through blockchain technology.

## Features

- Create fitness challenges with detailed workout plans and duration settings
- Join challenges using STX tokens with direct trainer compensation
- Track complete participation history and progress logs
- Head coach validation system for challenge quality assurance
- Immutable record of all fitness activities and achievements

## Smart Contract Functions

### Public Functions

- `create-challenge`: Trainers can create fitness challenges with workout plans and entry fees
- `join-challenge`: Participants can join challenges by paying trainers
- `validate-challenge`: Head coach can validate challenge quality and effectiveness

### Read-Only Functions

- `get-challenge`: Retrieve complete challenge information and trainer details
- `get-participation-log`: View specific participation and progress entries
- `get-participation-count`: Check total number of participants for a challenge

## Development

Built using Clarity smart contracts on the Stacks blockchain for transparent fitness challenge management.

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks CLI](https://github.com/blockstack/stacks.js)

### Testing

Run tests using Clarinet:

```bash
clarinet test