import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/back_title_bar.dart';
import 'models/evidence.dart';

/// Report an issue → Pin on map. The pin stays in the middle of the screen
/// and the user moves the map under it. "Use this location" returns the
/// spot as a [PinnedLocation] (pop with a result, like resolving a promise).
class LocationPickerScreen extends StatefulWidget {
  /// Where to start: the pin chosen before, or null to start at the user's
  /// own location.
  final PinnedLocation? initial;

  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  /// Where the map opens if there's no earlier pin and no GPS position yet:
  /// central Israel, where the app's users live.
  static const _fallbackCenter = LatLng(32.0853, 34.7818);
  static const _closeZoom = 16.0;

  GoogleMapController? _map;
  late LatLng _center = switch (widget.initial) {
    final pin? => LatLng(pin.latitude, pin.longitude),
    null => _fallbackCenter,
  };
  bool _hasLocationAccess = false;

  @override
  void initState() {
    super.initState();
    _findUser();
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  /// Asks for location access (to show the blue dot and "my location"
  /// button) and, if there's no earlier pin, moves the map to the user.
  /// Without access the map still works; they just start further away.
  Future<void> _findUser() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      if (!mounted) return;
      setState(() => _hasLocationAccess = true);
      if (widget.initial != null) return;

      final position = await Geolocator.getCurrentPosition();
      await _map?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          _closeZoom,
        ),
      );
    } catch (_) {
      // No position (e.g. timed out indoors): stay where the map is.
    }
  }

  void _confirm() => context.pop(
    PinnedLocation(latitude: _center.latitude, longitude: _center.longitude),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: widget.initial == null ? 12 : _closeZoom,
            ),
            onMapCreated: (controller) => _map = controller,
            // Every frame while the map moves: the pin is always at the
            // center, so the center is the chosen spot.
            onCameraMove: (position) => _center = position.target,
            myLocationEnabled: _hasLocationAccess,
            myLocationButtonEnabled: _hasLocationAccess,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            // Keeps Google's buttons clear of the title bar and the button.
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 64,
              bottom: 96,
            ),
          ),
          // The pin, drawn over the map rather than as a map marker so it
          // stays put while the map moves. Lifted by half its height so its
          // tip (not its middle) marks the spot.
          Center(
            child: Transform.translate(
              offset: const Offset(0, -_pinSize / 2),
              child: IgnorePointer(
                child: SvgPicture.asset(
                  'assets/icons/map_pin.svg',
                  width: _pinSize,
                  height: _pinSize,
                  colorFilter: ColorFilter.mode(colors.accent, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: TSizes.xs,
                      children: [
                        BackTitleBar(
                          title: l10n.pinLocationTitle,
                          fallbackLocation: '/report-issue',
                        ),
                        Text(
                          l10n.pinLocationHint,
                          style: TTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _confirm,
                    child: Text(l10n.useThisLocation),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const double _pinSize = 40;
}

/// A white rounded panel floating over the map.
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(TSizes.cardRadius),
    ),
    child: Padding(padding: const EdgeInsets.all(TSizes.md), child: child),
  );
}
