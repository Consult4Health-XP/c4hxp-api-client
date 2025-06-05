# HL7 Example Files

This directory contains **sanitized** HL7 example files for development and testing purposes. All real lab names, provider information, NPI numbers, and CLIA numbers have been replaced with dummy data to protect sensitive information.

## Files

- `demo_lab_sample.hl7` - STI screening panel example
- `hormone_panel_sample.hl7` - Male hormone panel example  
- `fertility_panel_sample.hl7` - Female reproductive health panel example
- `sample_rejection.hl7` - Sample rejection example

## Sanitized Data

The following real data has been replaced with dummy values:

- **Lab Names**: All changed to "Demo Labs" or "DEMOLAB"
- **Provider Organizations**: All changed to "Demo Health Inc." or "Demo Medical Provider"
- **NPI Numbers**: All changed to 9999999999
- **CLIA Numbers**: All changed to 99D9999999
- **Phone Numbers**: All changed to (555)555-0000 variations
- **Addresses**: All changed to "100 Demo Avenue, Demoville, CA 99999"
- **Panel Names**: Specific panel names changed to generic descriptions

## Purpose

These files are used for:
- API integration testing
- HL7 parsing development
- Documentation examples
- Developer onboarding

## Real Data

Original files with real lab and provider information are stored in a private directory that is excluded from version control. 