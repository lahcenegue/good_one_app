import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../Providers/user_state_provider.dart';
import '../Widgets/booking/contractor_list_item.dart';
import 'contractor_profile.dart';

class ContractorsByService extends StatefulWidget {
  final int? serviceId;
  final String? title;

  const ContractorsByService({
    super.key,
    required this.serviceId,
    required this.title,
  });

  @override
  State<ContractorsByService> createState() => _ContractorsByServiceState();
}

class _ContractorsByServiceState extends State<ContractorsByService> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userManager =
          Provider.of<UserStateProvider>(context, listen: false);
      userManager.fetchContractorsByService(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStateProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title ?? ''),
          ),
          body: Column(
            children: [
              _buildSearchBar(context, userManager),
              Expanded(
                child: _buildContractorsList(context, userManager),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, UserStateProvider userManager) {
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(15)),
      child: TextField(
        onChanged: userManager.updateContractorsByServiceSearch,
        decoration: InputDecoration(
          hintText: 'Search contractors',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildContractorsList(
      BuildContext context, UserStateProvider userManager) {
    final filteredContractors = userManager.contractorsByService;

    if (userManager.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredContractors.isEmpty) {
      return Center(
        child: Text(
          'No contractors found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.getAdaptiveSize(15)),
      itemCount: filteredContractors.length,
      itemBuilder: (context, index) {
        return ContractorListItem(
          contractor: filteredContractors[index],
          onFavorite: () {},
          onTap: () {
            userManager.setSelectedContractor(filteredContractors[index]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContractorProfile(),
              ),
            );
          },
        );
      },
    );
  }
}
