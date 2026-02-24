# frozen_string_literal: true

# Service to generate QR codes for team registration URLs
class QrGeneratorService
  def initialize(url)
    @url = url
  end

  # Generate QR code as SVG string
  def to_svg
    qrcode = RQRCode::QRCode.new(@url)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true,
      viewbox: true
    )
  end

  # Generate QR code as PNG string (base64)
  def to_png_base64
    qrcode = RQRCode::QRCode.new(@url)
    png = qrcode.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: "white",
      color: "black",
      size: 300,
      border_modules: 2,
      module_px_size: 6
    )
    Base64.strict_encode64(png.to_s)
  end
end
