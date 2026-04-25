// Shared constants — mirrors Flutter app_constants.dart
export const APP = {
  name: 'NGO Volunteer App',
  orgName: 'Hamesha Rahein Apke Saath',
  tagline: 'One Society, One Heartbeat',
  version: '1.0.0',
  description: 'A comprehensive platform for managing NGO operations, volunteer coordination, and community impact.',
};

export const COLLECTIONS = {
  users: 'users',
  campaigns: 'campaigns',
  volunteers: 'volunteers',
  donations: 'donations',
  announcements: 'announcements',
  campaignPhotos: 'campaign_photos',
  beneficiaries: 'beneficiaries',
  expenses: 'expenses',
  distributions: 'distributions',
  feedback: 'feedback',
  activityLog: 'activity_log',
};

export const STORAGE_PATHS = {
  profilePhotos: 'profile_photos',
  campaignCovers: 'campaign_covers',
  campaignPhotos: 'campaign_photos',
};

export const CAMPAIGN_TYPES = {
  winterDrive: { label: 'Winter Drive', icon: '❄️', color: '#42A5F5' },
  ramadan: { label: 'Ramadan', icon: '🌙', color: '#66BB6A' },
  eid: { label: 'Eid', icon: '🎉', color: '#FFCA28' },
  orphanage: { label: 'Orphanage', icon: '🏠', color: '#EF5350' },
  medical: { label: 'Medical', icon: '🏥', color: '#7E57C2' },
  education: { label: 'Education', icon: '📚', color: '#26C6DA' },
  custom: { label: 'Custom', icon: '📋', color: '#78909C' },
};

export const CAMPAIGN_STATUS = {
  upcoming: { label: 'Upcoming', color: '#29B6F6' },
  active: { label: 'Active', color: '#43A047' },
  completed: { label: 'Completed', color: '#2E7D32' },
  cancelled: { label: 'Cancelled', color: '#E53935' },
};

export const NAV_LINKS = [
  { label: 'Home', href: '/' },
  { label: 'About', href: '/about' },
  { label: 'Campaigns', href: '/campaigns' },
  { label: 'Donate', href: '/donate' },
  { label: 'Contact', href: '/contact' },
];

export const SOCIAL_LINKS = {
  instagram: 'https://www.instagram.com/hamesha.rahein.apke.saath/',
  facebook: 'https://www.facebook.com/share/16TfUbQzWp/',
  tiktok: 'https://www.tiktok.com/@hamesha.rahein.apke.saath',
};
