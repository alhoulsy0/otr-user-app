class StoreBranchModel {
  int? id;
  int? storeId;
  String? name;
  String? nameAr;
  String? address;
  String? addressAr;
  double? latitude;
  double? longitude;
  String? phone;
  int? status;
  int? isDefault;
  double? distance;
  bool? isNearest;

  StoreBranchModel({
    this.id,
    this.storeId,
    this.name,
    this.nameAr,
    this.address,
    this.addressAr,
    this.latitude,
    this.longitude,
    this.phone,
    this.status,
    this.isDefault,
    this.distance,
    this.isNearest,
  });

  StoreBranchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    storeId = json['store_id'] != null ? int.tryParse(json['store_id'].toString()) : null;
    name = json['name'];
    nameAr = json['name_ar'];
    address = json['address'];
    addressAr = json['address_ar'];
    latitude = json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null;
    longitude = json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null;
    phone = json['phone'];
    status = json['status'] != null ? int.tryParse(json['status'].toString()) : null;
    isDefault = json['is_default'] != null ? int.tryParse(json['is_default'].toString()) : null;
    distance = json['distance'] != null ? double.tryParse(json['distance'].toString()) : null;
    isNearest = json['is_nearest'] == true || json['is_nearest'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['address'] = address;
    data['address_ar'] = addressAr;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['phone'] = phone;
    data['status'] = status;
    data['is_default'] = isDefault;
    data['distance'] = distance;
    data['is_nearest'] = isNearest;
    return data;
  }

  String getDisplayName(bool isArabic) {
    if (isArabic && nameAr != null && nameAr!.trim().isNotEmpty) {
      return nameAr!;
    }
    return name ?? '';
  }

  String getDisplayAddress(bool isArabic) {
    if (isArabic && addressAr != null && addressAr!.trim().isNotEmpty) {
      return addressAr!;
    }
    return address ?? '';
  }
}
