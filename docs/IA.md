# NDIS Connect - Information Architecture

## Personas

### Primary: NDIS Participant
- **Age**: 18-65, diverse abilities
- **Goals**: Manage NDIS plan, track budgets, find services, coordinate support
- **Pain Points**: Complex NDIS system, scattered information, accessibility barriers
- **Tech Comfort**: Basic to intermediate mobile usage

### Secondary: NDIS Provider
- **Age**: 25-55, healthcare/support professionals
- **Goals**: Manage clients, schedule appointments, track services, communicate
- **Pain Points**: Multiple client management, documentation, coordination
- **Tech Comfort**: Intermediate to advanced mobile usage

## Core User Journeys

### Participant Journey
1. **Onboarding/Consent** → Welcome, accessibility preferences, privacy consent
2. **Link myGov/NDIS** → Connect to NDIS portal (placeholder integration)
3. **Dashboard** → Budget overview, upcoming appointments, quick actions
4. **Budgets** → Category breakdown, spending tracking, alerts
5. **Claims** → Submit receipts, track processing, history
6. **Services Map** → Find providers, filter by needs, contact
7. **Messages** → Secure chat with providers, support circle
8. **Support Circle** → Manage family/carers, permissions, notifications
9. **Calendar** → Appointments, reminders, availability
10. **Settings/Accessibility** → Text scale, contrast, reduced motion, privacy

### Provider Journey
1. **Onboarding/Verify** → Professional verification, service categories
2. **Client List** → Active participants, service history, notes
3. **Appointments** → Schedule, reschedule, notes, outcomes
4. **Messages** → Secure communication with participants
5. **Tasks** → Service delivery tracking, documentation

## Success Metrics
- **Accessibility**: WCAG 2.2 AA compliance, 4.5:1 contrast ratio
- **Usability**: <3 taps to key actions, 60fps performance
- **Engagement**: Daily active usage, feature adoption
- **Support**: Reduced support tickets, positive feedback

## Navigation Map
```
Splash → Role Selection → Onboarding → Dashboard
                                    ↓
                    ┌─────────────────────────────────┐
                    │        Main Navigation          │
                    ├─────────────────────────────────┤
                    │ Dashboard │ Budgets │ Services  │
                    │ Calendar  │ Messages│ Support   │
                    │ Settings  │ Profile │ Help      │
                    └─────────────────────────────────┘
```

## Information Hierarchy
1. **Critical**: Budget status, upcoming appointments, urgent messages
2. **Important**: Service search, claims history, support circle
3. **Secondary**: Settings, help, analytics, preferences

## Content Strategy
- **Tone**: Supportive, clear, empowering
- **Language**: Plain English, NDIS terminology explained
- **Visual**: High contrast, large touch targets, clear icons
- **Feedback**: Immediate, optimistic, actionable
