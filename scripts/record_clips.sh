#!/usr/bin/env bash
# ==============================================================================
# YaYa Camera-Ready Demo Clips Recorder
# Produces clean, labeled 60fps screen recordings and final-frame stills
# for the SVSD 7-minute competition pitch video.
# ==============================================================================
set -euo pipefail

DEV_DIR="/Applications/Xcode.app/Contents/Developer"
export DEVELOPER_DIR="$DEV_DIR"

# Target simulator: iPhone 17 Pro
SIM_UDID="${SIM_UDID:-DC75C333-913D-4A11-8340-2DB6DAAC6805}"
BUNDLE_ID="design.svsd.branch"
BASE_DIR="$HOME/Desktop/YaYa-Demo-Clips"

mkdir -p "$BASE_DIR"/{01_Brand,02_Scenario2_Individual,03_Solo_Session,04_Scenario1_Friction_Team,05_Projects_LiveMap,06_Insights,07_Profile,08_Export,09_Guest,10_Walkthroughs}

setup_simulator() {
  echo "==> Configuring iPhone 17 Pro ($SIM_UDID)..."
  xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
  xcrun simctl ui "$SIM_UDID" appearance light
  xcrun simctl status_bar "$SIM_UDID" override \
    --time "9:41" \
    --dataNetwork "wifi" \
    --wifiMode "active" \
    --wifiBars 3 \
    --cellularMode "active" \
    --cellularBars 4 \
    --batteryState "charged" \
    --batteryLevel 100
}

record_clip() {
  local section="$1"
  local name="$2"
  local duration="$3"
  shift 3
  local launch_args=("$@")

  local out_folder="$BASE_DIR/$section"
  local mov_file="$out_folder/${name}.mov"
  local png_file="$out_folder/${name}.png"

  echo "------------------------------------------------------------------"
  echo "==> Recording [$section] $name (${duration}s)"
  echo "    Args: ${launch_args[*]:-none}"
  echo "------------------------------------------------------------------"

  # Terminate any existing instance
  xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" 2>/dev/null || true
  sleep 0.5

  # Start video recording
  xcrun simctl io "$SIM_UDID" recordVideo --codec h264 --force "$mov_file" &
  local rec_pid=$!
  sleep 0.5

  # 1.0s lead-in hold
  sleep 1.0

  # Launch app with requested args
  if [ ${#launch_args[@]} -gt 0 ]; then
    xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID" "${launch_args[@]}"
  else
    xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID"
  fi

  # Sleep for the clip duration
  sleep "$duration"

  # Capture still of final frame
  xcrun simctl io "$SIM_UDID" screenshot "$png_file"

  # 1.5s post-hold before ending recording
  sleep 1.5

  # Stop recording cleanly with SIGINT so headers finalize
  kill -SIGINT "$rec_pid" 2>/dev/null || true
  wait "$rec_pid" 2>/dev/null || true

  if [ -f "$mov_file" ] && [ -f "$png_file" ]; then
    echo " [OK] Saved: $mov_file ($(ls -lh "$mov_file" | awk '{print $5}'))"
  else
    echo " [FAILED] Missing output files for $name"
  fi
}

setup_simulator

TARGET_CLIP="${1:-all}"

case "$TARGET_CLIP" in
  00_launch-blink)
    record_clip "01_Brand" "00_launch-blink" 3.8
    ;;
  01_welcome)
    record_clip "01_Brand" "01_welcome" 4.0 -noSplash
    ;;
  02_signup-sheet)
    record_clip "02_Scenario2_Individual" "02_signup-sheet" 4.0 -signIn
    ;;
  03_intro-morphing-sprite)
    record_clip "02_Scenario2_Individual" "03_intro-morphing-sprite" 5.0 -onboardingIntro
    ;;
  04_quiz)
    record_clip "02_Scenario2_Individual" "04_quiz" 5.0 -onboardingQuiz -quizSelected
    ;;
  05_talk-it-through)
    record_clip "02_Scenario2_Individual" "05_talk-it-through" 5.0 -onboardingTalkSpeaking
    ;;
  06_reveal)
    record_clip "02_Scenario2_Individual" "06_reveal" 5.0 -onboardingReveal -revealSpark
    ;;
  07_profile-name)
    record_clip "02_Scenario2_Individual" "07_profile-name" 7.5 -demoTypeProfile
    ;;
  08_profile-photo-option)
    record_clip "02_Scenario2_Individual" "08_profile-photo-option" 4.0 -onboardingProfileFilled
    ;;
  09_integrations)
    record_clip "02_Scenario2_Individual" "09_integrations" 5.0 -onboardingIntegrations -integrationsConnected
    ;;
  10_sync)
    record_clip "02_Scenario2_Individual" "10_sync" 5.5 -onboardingSyncing
    ;;
  11_session-ready)
    record_clip "03_Solo_Session" "11_session-ready" 4.0 -collaborationReady
    ;;
  12_solo-live)
    record_clip "03_Solo_Session" "12_solo-live" 22.0 -sessionLive
    ;;
  13_camera-capture)
    record_clip "03_Solo_Session" "13_camera-capture" 4.5 -collaborationReady -seedCapturePhoto
    ;;
  14_paste-link)
    record_clip "03_Solo_Session" "14_paste-link" 4.5 -collaborationReady -seedCaptureLink
    ;;
  15_takeaways-arrival)
    record_clip "03_Solo_Session" "15_takeaways-arrival" 5.5 -collaborationTakeaways -takeawaysReplay
    ;;
  16_takeaways-explore)
    record_clip "03_Solo_Session" "16_takeaways-explore" 5.0 -collaborationTakeaways -demoAutoTapKnowledge
    ;;
  17_takeaways-flat)
    record_clip "03_Solo_Session" "17_takeaways-flat" 4.5 -collaborationTakeaways -takeawaysFlat
    ;;
  18_team-toggle)
    record_clip "04_Scenario1_Friction_Team" "18_team-toggle" 4.5 -collaborationReady -sessionGroup
    ;;
  19_team-live)
    record_clip "04_Scenario1_Friction_Team" "19_team-live" 26.0 -sessionLive -sessionGroup
    ;;
  20_team-receipt)
    record_clip "04_Scenario1_Friction_Team" "20_team-receipt" 5.5 -receiptIso -sessionGroup
    ;;
  21_moment-sheet)
    record_clip "04_Scenario1_Friction_Team" "21_moment-sheet" 5.5 -momentDetail
    ;;
  22_projects-live)
    record_clip "05_Projects_LiveMap" "22_projects-live" 5.5 -tabLiveMapLive
    ;;
  23_combination)
    record_clip "05_Projects_LiveMap" "23_combination" 5.0 -testCombinationMoment
    ;;
  24_friction-resolve)
    record_clip "05_Projects_LiveMap" "24_friction-resolve" 5.0 -testFrictionSheet
    ;;
  25_filters-isolate)
    record_clip "05_Projects_LiveMap" "25_filters-isolate" 5.0 -testActorIsolated
    ;;
  26_insights-dated)
    record_clip "06_Insights" "26_insights-dated" 5.0 -tabKnowledgeDated
    ;;
  27_insights-live)
    record_clip "06_Insights" "27_insights-live" 5.0 -tabKnowledgeLive
    ;;
  28_profile)
    record_clip "07_Profile" "28_profile" 5.0 -tabProfile -profileScrollThinking
    ;;
  29_export)
    record_clip "08_Export" "29_export" 5.5 -exportFlow
    ;;
  30_guest)
    record_clip "09_Guest" "30_guest" 4.5 -guestReady
    ;;
  31_walkthrough-onboarding-full)
    record_clip "10_Walkthroughs" "31_walkthrough-onboarding-full" 18.0 -autoplayOnboarding quiz
    ;;
  32_walkthrough-solo-session-full)
    record_clip "10_Walkthroughs" "32_walkthrough-solo-session-full" 24.0 -sessionLive
    ;;
  33_walkthrough-team-session-full)
    record_clip "10_Walkthroughs" "33_walkthrough-team-session-full" 28.0 -sessionLive -sessionGroup
    ;;
  all)
    echo "==> Recording ALL demo clips and walkthroughs..."
    "$0" 00_launch-blink
    "$0" 01_welcome
    "$0" 02_signup-sheet
    "$0" 03_intro-morphing-sprite
    "$0" 04_quiz
    "$0" 05_talk-it-through
    "$0" 06_reveal
    "$0" 07_profile-name
    "$0" 08_profile-photo-option
    "$0" 09_integrations
    "$0" 10_sync
    "$0" 11_session-ready
    "$0" 12_solo-live
    "$0" 13_camera-capture
    "$0" 14_paste-link
    "$0" 15_takeaways-arrival
    "$0" 16_takeaways-explore
    "$0" 17_takeaways-flat
    "$0" 18_team-toggle
    "$0" 19_team-live
    "$0" 20_team-receipt
    "$0" 21_moment-sheet
    "$0" 22_projects-live
    "$0" 23_combination
    "$0" 24_friction-resolve
    "$0" 25_filters-isolate
    "$0" 26_insights-dated
    "$0" 27_insights-live
    "$0" 28_profile
    "$0" 29_export
    "$0" 30_guest
    "$0" 31_walkthrough-onboarding-full
    "$0" 32_walkthrough-solo-session-full
    "$0" 33_walkthrough-team-session-full
    echo "==> All recordings complete!"
    ;;
  *)
    echo "Unknown clip: $TARGET_CLIP"
    exit 1
    ;;
esac
